# Ops Wrappers

PowerShell validation and operational tooling around the Terraform layers — the discipline worth keeping from `ocvs-deployment`, rebuilt as wrappers that never mutate Terraform-managed resources outside `terraform apply`:

- Multi-plane acceptance validation (OCI control plane, TLS/port probes, authenticated vCenter/NSX health) — reference: `ocvs-deployment\validate_ocvs.ps1`.
- Work-request forensics on SDDC create failures (logs, errors, console-history capture) — reference: `ocvs-deployment\sddc_create_phase5.ps1` recovery path.
- Operator-/32 drift detection for the optional public-management pattern (report + `terraform plan`, not direct API writes).

Not yet implemented.
