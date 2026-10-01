variable "compartment_ocid" {
  type = string
}

variable "availability_domain" {
  type = string
}

variable "sddc_display_name" {
  type = string

  validation {
    condition     = length(var.sddc_display_name) <= 16
    error_message = "OCVS rejects SDDC display names longer than 16 characters."
  }
}

variable "vmware_software_version" {
  type = string
}

variable "esxi_software_version" {
  type = string
}

variable "esxi_hosts_count" {
  type = number
}

variable "is_single_host_sddc" {
  type = bool
}

variable "host_shape" {
  type = string
}

variable "initial_commitment" {
  type = string
}

variable "ssh_authorized_keys" {
  type = string
}

variable "vcf_byol_id" {
  description = "Home-region VCF BYOL registration OCID."
  type        = string
}

variable "vcf_byol_units" {
  type = number
}

variable "provisioning_subnet_id" {
  type = string
}

variable "vlan_ids" {
  description = "Map from the network module: vsphere, vmotion, vsan, nsx_vtep, nsx_edge_vtep, nsx_edge_uplink1, nsx_edge_uplink2, replication, hcx, provisioning_vlan."
  type        = map(string)
}

variable "freeform_tags" {
  type    = map(string)
  default = {}
}
