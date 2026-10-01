terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

# Wizard-parity OCVS network layout (docs/design-decisions.md D2-D5, D9):
# equal /25 slices of sddc_cidr, one route table and one NSG per VLAN, NAT
# default route only on the vSphere VLAN (OCVS/HCX sanity requirement) and
# Edge Uplink 1 (workload egress path).

locals {
  # Slice order is the address plan; do not reorder existing entries.
  segment_index = {
    provisioning_subnet = 0
    vsphere             = 1
    vmotion             = 2
    vsan                = 3
    nsx_vtep            = 4
    nsx_edge_vtep       = 5
    nsx_edge_uplink1    = 6
    nsx_edge_uplink2    = 7
    replication         = 8
    hcx                 = 9
    provisioning_vlan   = 10
  }

  # Wizard slicing: 16 equal prefix+4 segments of any supported CIDR
  # (/21 -> /25 ... /24 -> /28). Eleven of the sixteen slices are used.
  segment_newbits = 4
  segment_cidrs = {
    for name, index in local.segment_index :
    name => cidrsubnet(var.sddc_cidr, local.segment_newbits, index)
  }

  vlan_names = [for name in keys(local.segment_index) : name if name != "provisioning_subnet"]

  # D4: NAT default route only where Oracle prescribes it.
  nat_routed_vlans = ["vsphere", "nsx_edge_uplink1"]

  vlan_route_rules = {
    for name in local.vlan_names :
    name => concat(
      contains(local.nat_routed_vlans, name) ? [{
        destination       = "0.0.0.0/0"
        network_entity_id = oci_core_nat_gateway.nat.id
        description       = "Default egress through NAT (OCVS sanity requirement)"
      }] : [],
      # D5: admin-/32 IGW return path, vSphere VLAN only, opt-in.
      var.enable_public_management && name == "vsphere" ? [{
        destination       = var.admin_cidr
        network_entity_id = oci_core_internet_gateway.igw.id
        description       = "Operator /32 return path for public management IPs (lab only)"
      }] : []
    )
  }
}

# ---------- VCN and gateways ----------

resource "oci_core_vcn" "sddc" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "${var.name_prefix}-vcn"
  dns_label      = "vcfsddc"
  freeform_tags  = var.freeform_tags

  lifecycle {
    precondition {
      condition = (
        tonumber(split("/", var.sddc_cidr)[1]) >= tonumber(split("/", var.vcn_cidr)[1]) &&
        can(cidrhost("${split("/", var.sddc_cidr)[0]}/${split("/", var.vcn_cidr)[1]}", 0)) &&
        cidrhost("${split("/", var.sddc_cidr)[0]}/${split("/", var.vcn_cidr)[1]}", 0) == cidrhost(var.vcn_cidr, 0)
      )
      error_message = "sddc_cidr must be contained within vcn_cidr."
    }
  }
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.sddc.id
  display_name   = "${var.name_prefix}-igw"
  enabled        = true
  freeform_tags  = var.freeform_tags
}

resource "oci_core_nat_gateway" "nat" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.sddc.id
  display_name   = "${var.name_prefix}-nat"
  block_traffic  = false
  freeform_tags  = var.freeform_tags
}

# ---------- Per-VLAN route tables (D3) ----------

resource "oci_core_route_table" "vlan" {
  for_each = toset(local.vlan_names)

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.sddc.id
  display_name   = "${var.name_prefix}-${replace(each.key, "_", "-")}-rt"
  freeform_tags  = var.freeform_tags

  dynamic "route_rules" {
    for_each = local.vlan_route_rules[each.key]
    content {
      destination       = route_rules.value.destination
      destination_type  = "CIDR_BLOCK"
      network_entity_id = route_rules.value.network_entity_id
      description       = route_rules.value.description
    }
  }
}

resource "oci_core_route_table" "provisioning_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.sddc.id
  display_name   = "${var.name_prefix}-provisioning-subnet-rt"
  freeform_tags  = var.freeform_tags
  # Intentionally empty: intra-VCN routing is implicit; the wizard adds no
  # gateway routes to the provisioning subnet at create time.
}

# ---------- Per-VLAN NSGs with the wizard's baseline rules ----------

resource "oci_core_network_security_group" "vlan" {
  for_each = toset(local.vlan_names)

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.sddc.id
  display_name   = "${var.name_prefix}-${replace(each.key, "_", "-")}-nsg"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_network_security_group_security_rule" "vlan_ingress_vcn" {
  for_each = toset(local.vlan_names)

  network_security_group_id = oci_core_network_security_group.vlan[each.key].id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  description               = "Required intra-VCN VMware traffic (wizard baseline)"
}

resource "oci_core_network_security_group_security_rule" "vlan_egress_all" {
  for_each = toset(local.vlan_names)

  network_security_group_id = oci_core_network_security_group.vlan[each.key].id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "Required outbound traffic (wizard baseline)"
}

# Optional 443-only management NSG for public vCenter/NSX access (D5).
resource "oci_core_network_security_group" "management" {
  count = var.enable_public_management ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.sddc.id
  display_name   = "${var.name_prefix}-management-nsg"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_network_security_group_security_rule" "management_https" {
  count = var.enable_public_management ? 1 : 0

  network_security_group_id = oci_core_network_security_group.management[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.admin_cidr
  source_type               = "CIDR_BLOCK"
  description               = "vCenter and NSX Manager HTTPS from the operator /32 only"

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

# ---------- Provisioning subnet (private, D9) ----------

resource "oci_core_security_list" "provisioning" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.sddc.id
  display_name   = "${var.name_prefix}-provisioning-sl"
  freeform_tags  = var.freeform_tags

  ingress_security_rules {
    protocol    = "all"
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    description = "Required intra-VCN VMware traffic (wizard baseline)"
  }

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description      = "Required outbound traffic (wizard baseline)"
  }
}

resource "oci_core_subnet" "provisioning" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.sddc.id
  cidr_block                 = local.segment_cidrs["provisioning_subnet"]
  display_name               = "${var.name_prefix}-provisioning-subnet"
  dns_label                  = "provision"
  route_table_id             = oci_core_route_table.provisioning_subnet.id
  security_list_ids          = [oci_core_security_list.provisioning.id]
  prohibit_public_ip_on_vnic = true
  freeform_tags              = var.freeform_tags
}

# ---------- VMware VLANs ----------

resource "oci_core_vlan" "sddc" {
  for_each = toset(local.vlan_names)

  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.sddc.id
  availability_domain = var.availability_domain
  cidr_block          = local.segment_cidrs[each.key]
  display_name        = "${var.name_prefix}-${replace(each.key, "_", "-")}-vlan"
  route_table_id      = oci_core_route_table.vlan[each.key].id
  nsg_ids = concat(
    [oci_core_network_security_group.vlan[each.key].id],
    var.enable_public_management && each.key == "vsphere" ? [oci_core_network_security_group.management[0].id] : []
  )
  freeform_tags = var.freeform_tags
  # 802.1Q tag left to OCI auto-assignment (wizard-equivalent behavior).
}
