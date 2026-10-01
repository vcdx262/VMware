terraform {
  required_providers {
    oci = {
      source                = "oracle/oci"
      configuration_aliases = [oci, oci.home]
    }
  }
}

# The shared BYOL registration lives in the tenancy home region. Verifying it
# here fails the plan before any billable create when the registration is
# inactive, the wrong type, or short on units.
data "oci_ocvp_byol" "registration" {
  provider = oci.home
  byol_id  = var.vcf_byol_id
}

# Regional allocation carved from the shared home-region VCF BYOL registration.
resource "oci_ocvp_byol_allocation" "vcf" {
  compartment_id  = var.compartment_ocid
  byol_id         = var.vcf_byol_id
  allocated_units = var.vcf_byol_units
  display_name    = "${var.sddc_display_name}-vcf${var.vcf_byol_units}"
  freeform_tags   = var.freeform_tags
}

resource "oci_ocvp_sddc" "this" {
  compartment_id          = var.compartment_ocid
  display_name            = var.sddc_display_name
  vmware_software_version = var.vmware_software_version
  esxi_software_version   = var.esxi_software_version
  ssh_authorized_keys     = var.ssh_authorized_keys
  is_single_host_sddc     = var.is_single_host_sddc
  # VCF BYOL mandates HCX Enterprise on this create path. Per the provider
  # docs, hcx_action = "UPGRADE" at creation deploys the SDDC with HCX
  # Enterprise enabled (hcx_mode itself is a computed attribute); after
  # create the persisted value is a stable no-op (action fires only on
  # change). If this resource is ever re-imported (state rebuild), remove
  # hcx_action from the config before importing per the provider migration
  # note — the SDDC is already Enterprise and re-adding it would fire an
  # upgrade call.
  is_hcx_enabled = true
  hcx_action     = "UPGRADE"
  freeform_tags  = var.freeform_tags

  initial_configuration {
    initial_cluster_configurations {
      compute_availability_domain    = var.availability_domain
      vsphere_type                   = "MANAGEMENT"
      esxi_hosts_count               = var.esxi_hosts_count
      initial_host_shape_name        = var.host_shape
      initial_commitment             = var.initial_commitment
      display_name                   = "${var.sddc_display_name}-mgmt"
      instance_display_name_prefix   = "${var.sddc_display_name}-esxi"
      initial_vcf_byol_allocation_id = oci_ocvp_byol_allocation.vcf.id

      network_configuration {
        provisioning_subnet_id  = var.provisioning_subnet_id
        provisioning_vlan_id    = var.vlan_ids["provisioning_vlan"]
        vsphere_vlan_id         = var.vlan_ids["vsphere"]
        vmotion_vlan_id         = var.vlan_ids["vmotion"]
        vsan_vlan_id            = var.vlan_ids["vsan"]
        nsx_vtep_vlan_id        = var.vlan_ids["nsx_vtep"]
        nsx_edge_vtep_vlan_id   = var.vlan_ids["nsx_edge_vtep"]
        nsx_edge_uplink1vlan_id = var.vlan_ids["nsx_edge_uplink1"]
        nsx_edge_uplink2vlan_id = var.vlan_ids["nsx_edge_uplink2"]
        replication_vlan_id     = var.vlan_ids["replication"]
        hcx_vlan_id             = var.vlan_ids["hcx"]
      }
    }
  }

  timeouts {
    create = "6h"
    delete = "6h"
  }

  lifecycle {
    precondition {
      condition     = (var.esxi_hosts_count == 1) == var.is_single_host_sddc
      error_message = "is_single_host_sddc must be true exactly when esxi_hosts_count is 1; a mismatch is rejected by the OCVS API only after the billable create begins."
    }
    precondition {
      condition     = !var.is_single_host_sddc || contains(["HOUR", "MONTH"], var.initial_commitment)
      error_message = "Single-host SDDCs allow only HOUR or MONTH commitments."
    }
    precondition {
      condition     = data.oci_ocvp_byol.registration.state == "ACTIVE" && data.oci_ocvp_byol.registration.software_type == "VCF"
      error_message = "vcf_byol_id must reference an ACTIVE registration of software type VCF."
    }
    precondition {
      condition     = data.oci_ocvp_byol.registration.available_units >= var.vcf_byol_units
      error_message = "The VCF BYOL registration does not have enough unallocated units for vcf_byol_units."
    }
  }
}
