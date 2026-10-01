# Layer 1 — In-SDDC Substrate

Neutral workload substrate inside the SDDC: NSX overlay segments, Tier-1 routing, outbound SNAT, management-VCN isolation, vSphere folders/resource pools, content libraries.

Not yet implemented. Consumes layer 0 via `terraform output -json` from `../infra` (never its state file). Planned implementation: Terraform `vmware/nsxt` + `vmware/vsphere` providers, with the `ocvs-deployment` repo's `Initialize-OcvsWorkloadSubstrate.ps1` (LAB-CORE segment, SNAT to the Edge VIP, management null-route) as the functional reference.
