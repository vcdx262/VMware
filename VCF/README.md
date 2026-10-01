# VCF Deployment

Reusable, Terraform-based deployment artifact for Oracle Cloud VMware Solution (OCVS) SDDCs, built as the foundation for layering VCF-subscription components (Aria Suite / VCF Operations) on top.

This project supersedes the PowerShell-based `ocvs-deployment` foundation scripts for **infrastructure provisioning**. It incorporates the findings of the August 2026 wizard-parity review (internal wizard-parity review): per-VLAN route tables and NSGs, wizard-equal CIDR slicing, pinned ESXi artifact, operator-supplied SSH key, and a typed output contract for downstream layers.

## Layering model

| Layer | Directory | Tool | Owns |
|---|---|---|---|
| 0 — OCI infrastructure | `infra/` | Terraform (`oracle/oci`) | VCN, per-VLAN route tables + NSGs, provisioning subnet, VLANs, BYOL allocation, SDDC, optional public-management access |
| 1 — In-SDDC substrate | `substrate/` | Terraform `nsxt`/`vsphere` or PowerCLI | NSX segments, T1 routing, SNAT, folders, resource pools, content libraries |
| 2 — VCF components | `aria/` | Aria Suite Lifecycle + PowerCLI | ASL, WS1 Access, Aria Operations / Logs / Automation / Networks (see `docs/vcf-bom-5.2.4.md`) |
| Ops wrappers | `scripts/` | PowerShell | Validation, evidence capture, boundary management ported from `ocvs-deployment` |

A layer consumes the layer below only through its published outputs (`terraform output -json` for layer 0). No layer reaches into another layer's state.

## Quickstart (layer 0)

```powershell
cd infra
Copy-Item terraform.tfvars.example terraform.tfvars   # then edit values
terraform init
terraform plan -out sddc.tfplan
terraform apply sddc.tfplan
```

Deploying an SDDC is billable and slow (~2.5 h+). Always review the plan before applying.

## Documents

- `docs/vcf-bom-5.2.4.md` — verified component versions and VCF-subscription entitlements for the vSphere 8.0U3 stack.
- `docs/design-decisions.md` — why this layout differs from the old PowerShell repo (and where it deliberately matches the OCI console wizard).

## Relationship to `ocvs-deployment`

`D:\Claude\Projects\ocvs-deployment` remains the operational runbook for the currently-running lab SDDC (run `20260813T144620Z`). This repo targets the **next** deployment; nothing here imports or mutates the live run's resources.
