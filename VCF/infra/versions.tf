terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source = "oracle/oci"
      # >= 8.10 is required for the VCF 5.2 BYOL surface (byol allocations,
      # initial_vcf_byol_allocation_id). Pin below the next major.
      version = ">= 8.10.0, < 9.0.0"
    }
  }
}
