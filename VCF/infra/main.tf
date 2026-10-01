data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

locals {
  availability_domain = var.availability_domain != "" ? var.availability_domain : data.oci_identity_availability_domains.ads.availability_domains[0].name

  # Standard tag set required by AGENTS.md; var.freeform_tags may extend or
  # override it.
  tags = merge(
    {
      Project    = "vcf-deployment"
      ManagedBy  = "terraform"
      Deployment = var.name_prefix
    },
    var.freeform_tags
  )
}

module "network" {
  source = "./modules/network"

  compartment_ocid    = var.compartment_ocid
  availability_domain = local.availability_domain
  name_prefix         = var.name_prefix
  vcn_cidr            = var.vcn_cidr
  sddc_cidr           = var.sddc_cidr
  freeform_tags       = local.tags

  enable_public_management = var.enable_public_management
  admin_cidr               = var.admin_cidr
}

module "sddc" {
  source = "./modules/sddc"
  providers = {
    oci      = oci
    oci.home = oci.home
  }

  compartment_ocid    = var.compartment_ocid
  availability_domain = local.availability_domain

  sddc_display_name       = var.sddc_display_name
  vmware_software_version = var.vmware_software_version
  esxi_software_version   = var.esxi_software_version
  esxi_hosts_count        = var.esxi_hosts_count
  is_single_host_sddc     = var.is_single_host_sddc
  host_shape              = var.host_shape
  initial_commitment      = var.initial_commitment
  ssh_authorized_keys     = var.ssh_authorized_keys

  vcf_byol_id    = var.vcf_byol_id
  vcf_byol_units = var.vcf_byol_units

  provisioning_subnet_id = module.network.provisioning_subnet_id
  vlan_ids               = module.network.vlan_ids

  freeform_tags = local.tags
}

# ---------- Optional public management access (D5 — lab only) ----------
# Reserved public IPs mapped to the vCenter / NSX Manager private IPs. The
# matching admin-/32 -> IGW route and 443-only management NSG live in the
# network module, scoped to the vSphere VLAN alone.

resource "oci_core_public_ip" "vcenter" {
  count = var.enable_public_management ? 1 : 0

  compartment_id = var.compartment_ocid
  lifetime       = "RESERVED"
  display_name   = "${var.name_prefix}-vcenter-public-ip"
  private_ip_id  = module.sddc.vcenter_private_ip_id
  freeform_tags  = local.tags
}

resource "oci_core_public_ip" "nsx" {
  count = var.enable_public_management ? 1 : 0

  compartment_id = var.compartment_ocid
  lifetime       = "RESERVED"
  display_name   = "${var.name_prefix}-nsx-public-ip"
  private_ip_id  = module.sddc.nsx_manager_private_ip_id
  freeform_tags  = local.tags
}
