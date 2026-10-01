# ---------- Context ----------

variable "oci_profile" {
  description = "Profile name in ~/.oci/config used for API-key auth."
  type        = string
  default     = "OCVPTEST"
}

variable "region" {
  description = "Deployment region for the SDDC and all network resources."
  type        = string
  default     = "us-sanjose-1"
}

variable "home_region" {
  description = "Tenancy home region (BYOL registrations live here)."
  type        = string
  default     = "us-ashburn-1"
}

variable "compartment_ocid" {
  description = "Compartment for every resource this stack creates."
  type        = string
}

variable "availability_domain" {
  description = "Full AD name (e.g. WquQ:US-SANJOSE-1-AD-1). Empty selects the first AD in the region."
  type        = string
  default     = ""
}

variable "name_prefix" {
  description = "Prefix for OCI network/public-IP display names, and the default Deployment tag value. The SDDC name is set separately via sddc_display_name (16-char OCVS limit)."
  type        = string
  default     = "vcflab"
}

# ---------- Network (D2/D3/D4 in docs/design-decisions.md) ----------

variable "vcn_cidr" {
  description = "VCN CIDR. Must contain sddc_cidr and leave headroom for future clusters."
  type        = string
  default     = "10.10.0.0/16"
}

variable "sddc_cidr" {
  description = "Management CIDR sliced into 16 equal prefix+4 segments (the console wizard's slicing: /21 -> /25 ... /24 -> /28) for the provisioning subnet and the 10 VLANs. Per Oracle's sizing table, /24 supports up to 12 hosts and /21 up to 64."
  type        = string
  default     = "10.10.0.0/21"

  validation {
    condition = (
      tonumber(split("/", var.sddc_cidr)[1]) >= 16 &&
      tonumber(split("/", var.sddc_cidr)[1]) <= 24
    )
    error_message = "sddc_cidr must be between /16 and /24 (Oracle's minimum management CIDR is /24; wizard slicing is prefix+4)."
  }
}

# ---------- SDDC ----------

variable "sddc_display_name" {
  description = "SDDC display name. OCVS API limit is 16 characters."
  type        = string
  default     = "vcflab-sddc"

  validation {
    condition     = length(var.sddc_display_name) <= 16
    error_message = "OCVS rejects SDDC display names longer than 16 characters."
  }
}

variable "vmware_software_version" {
  description = "Pinned VMware bundle version (D6)."
  type        = string
  default     = "8.0 update 3"
}

variable "esxi_software_version" {
  description = "Pinned ESXi artifact (D6). Change only together with docs/vcf-bom-5.2.4.md."
  type        = string
  default     = "esxi8u3k-25595708-1"
}

variable "esxi_hosts_count" {
  description = "Host count for the management cluster. 1 = single-host lab (with is_single_host_sddc=true); 3+ = production-shaped."
  type        = number
  default     = 1
}

variable "is_single_host_sddc" {
  description = "Must be true when esxi_hosts_count is 1. Single-host SDDCs cannot be upgraded to multi-host later."
  type        = bool
  default     = true
}

variable "host_shape" {
  description = "ESXi bare-metal shape."
  type        = string
  default     = "BM.DenseIO2.52"
}

variable "initial_commitment" {
  description = "Billing commitment for the initial hosts (single-host SDDCs allow only HOUR or MONTH)."
  type        = string
  default     = "HOUR"
}

variable "ssh_authorized_keys" {
  description = "SSH public key(s) authorized on the ESXi hosts. Operator-supplied; nothing here generates key material (D7)."
  type        = string
}

# ---------- Licensing (VCF BYOL) ----------

variable "vcf_byol_id" {
  description = "OCID of the shared, ACTIVE VCF BYOL registration (home region). The stack creates a regional allocation from it."
  type        = string
}

variable "vcf_byol_units" {
  description = "Cores to allocate regionally for the SDDC. BM.DenseIO2.52 x 1 host = 52."
  type        = number
  default     = 52
}

# ---------- Optional public management access (D5 — lab only) ----------

variable "enable_public_management" {
  description = "Opt-in lab pattern: reserved public IPs on vCenter/NSX, admin-/32 IGW return route on the vSphere VLAN's route table only, 443-only management NSG. Never enable for production."
  type        = bool
  default     = false
}

variable "admin_cidr" {
  description = "Operator public IPv4 /32 allowed to reach vCenter/NSX on 443 when enable_public_management is true."
  type        = string
  default     = ""

  validation {
    condition = (
      var.enable_public_management
      ? can(cidrhost(var.admin_cidr, 0)) && endswith(var.admin_cidr, "/32")
      : var.admin_cidr == ""
    )
    error_message = "admin_cidr must be a valid IPv4 /32 when enable_public_management is true, and empty when it is false (a value with the flag off would be silently unused)."
  }
}

# ---------- Tags ----------

variable "freeform_tags" {
  description = "Additional tags merged over the standard set (Project, ManagedBy, Deployment) that main.tf applies to every resource."
  type        = map(string)
  default     = {}
}
