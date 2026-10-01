variable "compartment_ocid" {
  type = string
}

variable "availability_domain" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "vcn_cidr" {
  type = string
}

variable "sddc_cidr" {
  description = "Management CIDR, sliced into equal /25 segments (wizard-style)."
  type        = string
}

variable "enable_public_management" {
  type    = bool
  default = false
}

variable "admin_cidr" {
  description = "Operator /32; used only when enable_public_management is true."
  type        = string
  default     = ""
}

variable "freeform_tags" {
  type    = map(string)
  default = {}
}
