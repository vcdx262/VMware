# Typed output contract (D8). Downstream layers consume `terraform output -json`
# — never this stack's state file directly.

output "sddc_id" {
  value = module.sddc.sddc_id
}

output "vcenter_fqdn" {
  value = module.sddc.vcenter_fqdn
}

output "nsx_manager_fqdn" {
  value = module.sddc.nsx_manager_fqdn
}

output "vcenter_private_ip_id" {
  value = module.sddc.vcenter_private_ip_id
}

output "nsx_manager_private_ip_id" {
  value = module.sddc.nsx_manager_private_ip_id
}

output "hcx_fqdn" {
  value = module.sddc.hcx_fqdn
}

output "hcx_private_ip_id" {
  value = module.sddc.hcx_private_ip_id
}

output "vcn_id" {
  value = module.network.vcn_id
}

output "provisioning_subnet_id" {
  value = module.network.provisioning_subnet_id
}

output "vlan_ids" {
  description = "Map of segment key -> VLAN OCID for all 10 VMware VLANs."
  value       = module.network.vlan_ids
}

output "vlan_cidrs" {
  description = "Map of segment key -> CIDR, for address-plan documentation and overlap checks."
  value       = module.network.segment_cidrs
}

output "nsg_ids" {
  value = module.network.nsg_ids
}

output "route_table_ids" {
  value = module.network.route_table_ids
}

output "vcf_byol_allocation_id" {
  value = module.sddc.vcf_byol_allocation_id
}

output "vcenter_public_ip" {
  value = var.enable_public_management ? oci_core_public_ip.vcenter[0].ip_address : null
}

output "nsx_public_ip" {
  value = var.enable_public_management ? oci_core_public_ip.nsx[0].ip_address : null
}
