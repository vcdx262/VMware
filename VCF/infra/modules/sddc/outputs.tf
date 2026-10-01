output "sddc_id" {
  value = oci_ocvp_sddc.this.id
}

output "vcenter_fqdn" {
  value = oci_ocvp_sddc.this.vcenter_fqdn
}

output "nsx_manager_fqdn" {
  value = oci_ocvp_sddc.this.nsx_manager_fqdn
}

output "vcenter_private_ip_id" {
  value = oci_ocvp_sddc.this.vcenter_private_ip_id
}

output "nsx_manager_private_ip_id" {
  value = oci_ocvp_sddc.this.nsx_manager_private_ip_id
}

output "hcx_fqdn" {
  value = oci_ocvp_sddc.this.hcx_fqdn
}

output "hcx_private_ip_id" {
  value = oci_ocvp_sddc.this.hcx_private_ip_id
}

output "vcf_byol_allocation_id" {
  value = oci_ocvp_byol_allocation.vcf.id
}
