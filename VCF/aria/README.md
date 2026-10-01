# Layer 2 — VCF Components (Aria Suite)

Deployment of the customer-deployed VCF-subscription components onto the SDDC. Versions and order are pinned in `../docs/vcf-bom-5.2.4.md` — update that file in the same change as any version bump here.

Install order (KB 426230):

1. **Aria Suite Lifecycle 8.18.0 Patch 9** (build 25621957) — the LCM engine; deploy its OVA against vCenter first.
2. **Workspace ONE Access** (3.3.7 line, ASL-offered) — identity broker required by Aria Automation.
3. **Aria Operations 8.18.7** — standard vCenter/vSAN/NSX adapters (the OCVS management pack is EOGS).
4. **Aria Operations for Logs 8.18.7**
5. **Aria Automation 8.18.1 + CU5** — OCVS is consumed as standard vCenter + NSX-T cloud accounts.
6. **Aria Operations for Networks 6.14.3** — OCVS is a documented data source.

Not yet implemented. Planned: PowerCLI/REST runbook scripts for ASL bootstrap (OVA deploy, cert, binary mapping) and ASL environment requests for each product, consuming layer-0 outputs for vCenter/NSX endpoints.

Sizing note: the single BM.DenseIO2.52 host (768 GB) fits a small non-HA Aria stack for lab purposes; production-shaped Aria requires a multi-host SDDC.
