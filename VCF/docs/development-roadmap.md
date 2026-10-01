# Development Roadmap — SDDC Base + Independent VCF Component Modules

Goal: automation that (1) deploys a base single-host OCVS SDDC and (2) deploys each VCF-subscription component on top as an **independent module** — each consuming only the layer-0 output contract (`terraform output -json`) and its own config, never another module's internals. Researched and verified 2026-08-27; sources cited in the per-component sections.

## License position (VMUG Advantage)

The certification-unlocked VMUG Advantage grant (active Advantage membership + VCP-VCF exam) is documented as: **VCF 128 cores** (SKU VCF-CLD-FND), **vDefend Firewall w/ ATP 128 cores** (ANS-FW-ATP-B), **Avi Load Balancer Enterprise 12 Service Units** (ANS-VMW-ALB) — 1-year terms renewable twice via yearly refresher exam, personal/non-production use, keys + binaries via the Broadcom Certification License Portal (`support.broadcom.com/group/ecx/alpine-certificate`). No source documents a 120-core figure — **verify the actual counts and the vDefend key SKU (Firewall vs Firewall-with-ATP) in your portal**; ATP gates IDS/IPS, Malware Prevention, and NDR.

**Core math (at 128):** 1 × BM.DenseIO2.52 = 52 cores (76 spare) · 2 hosts = 104 (24 spare) · 3 hosts = 156 — over by 28. Single-host is the right fit. vDefend DFW on one host = exactly 52 cores. 12 Avi Service Units = SE vCPUs (controller consumes none) — comfortably covers a lab SE group.

**⚠ OCVS BYOL compliance register (decide before phase 1):**

| Fact | Status |
|---|---|
| Oracle BYOL registration is self-attested ("I confirm that I have **purchased** the above license for use on OCVS") and the data **is shared with Broadcom** | Documented |
| Oracle's stated eligibility: "VCF subscription entitlements **procured** from Broadcom (or authorized partners)" | Documented |
| VMUG keys are grants (not purchases) and do **not** appear as commercial entitlements in the Broadcom Support Portal | Documented |
| VMUG terms: personal, non-production, home-lab use; full EULA not public — cloud-hosted-lab permissibility | Undocumented |
| ⇒ Registering VMUG keys as OCVS BYOL is **undocumented at best and conflicts with the attestation text** | Assessment |
| In-guest licensing (Aria via ASL Locker, Avi key in controller, vDefend key in NSX Manager) involves **no Oracle registration at all** | Documented |
| vDefend key applies in NSX only when a **VCF-flavor base NSX key** is present (else error 3035); what Oracle installs on OCVS NSX is undocumented — check NSX **System → Licensing** first | Conditional |

Practical posture: the base-SDDC BYOL registration is a decision for the operator (the current lab ran on a pre-existing VCF registration in the tenancy); everything **above** the SDDC licenses in-guest and is a clean fit for the VMUG keys.

## Order of operations

Build in this order — each phase produces something usable and unblocks the next. Phases 4a and 8 are dependency-independent side tracks that can run any time after phase 2.

| # | Phase | Deliverable | Deployment tooling | Depends on |
|---|---|---|---|---|
| 0 | **SDDC infra** ✅ scaffolded | `infra/` Terraform: VCN, per-VLAN RTs/NSGs, VLANs, BYOL allocation, SDDC | Terraform `oracle/oci` | — |
| 1 | **First live deploy + validation port** | `terraform plan/apply` of a real SDDC; port the multi-plane validator to `scripts/` | Terraform + PowerShell wrappers | 0, license decision |
| 2 | **Substrate** | `substrate/` Terraform: appliance-mgmt + avi-mgmt + workload overlay segments, T1s/DHCP, vSphere folders/pools, **content library**, media-staging path for Broadcom binaries | Terraform `vmware/nsxt` + `vmware/vsphere`; PowerCLI for content-library uploads | 1 |
| 3 | **ASL (Aria Suite Lifecycle) 8.18 P9** | `aria/asl/`: OVA deploy + bootstrap (cert, NTP/DNS, Locker keys, binary mapping) | `govc`/PowerCLI OVA import → ASL REST API driven by PowerShell | 2 |
| 4 | **Workspace ONE Access** | `aria/ws1/`: globalenvironment request via ASL | ASL API (PowerShell) | 3 |
| 4a | **vDefend firewall + IDS/IPS** (side track — do early, it's nearly free) | `vdefend/`: license keys via NSX API, DFW policy-as-code, distributed IDS/IPS | NSX REST (`POST /api/v1/licenses`, base key before add-on) + Terraform `vmware/nsxt` **v3.12+** (`nsxt_policy_security_policy`, groups, context profiles; IDPS: `nsxt_policy_idps_cluster_config`, `_settings`, intrusion policies) | 1 (+ VCF-flavor base key check) |
| 5 | **Aria Operations 8.18.7 → Logs 8.18.7** | `aria/ops/`, `aria/logs/`: ASL environment requests; vCenter/vSAN/NSX adapters as code | ASL API (PowerShell) + product REST for adapters | 3 |
| 6 | **Aria Automation 8.18.1+CU5** | `aria/vra/`: ASL environment request; then cloud accounts (vCenter + NSX), projects, templates as code | ASL API (PowerShell) → Terraform `vmware/vra` provider for day-2 config | 4 |
| 7 | **Aria Operations for Networks 6.14.3** | `aria/vrni/`: platform + collector via ASL; data sources (vCenter, NSX, OCVS) as code | ASL API (PowerShell) + AON REST | 3 |
| 8 | **Avi Load Balancer 31.2.3** (side track) | `avi/`: Small controller (6 vCPU/32 GB/128 GB) on `avi-mgmt` segment; NSX-T Cloud connector; SE group; first VS | `govc import.ova` with `avi.mgmt-ip/mask/default-gw.CONTROLLER` props → REST bootstrap (password flip via `PUT /api/useraccount` CSRF flow, systemconfig, license) → Terraform `vmware/avi` **pinned to controller version** | 2 |
| 9 | **SSP (optional, resource-gated)** | Security Intelligence / ATP platform features — only if genuinely wanted | SSPI OVA + bundle upload (no Terraform provider exists) | 4a, ~150+ GB RAM budget |
| ✱ | **Validation harness** (continuous) | `scripts/`: per-module acceptance checks, evidence capture | PowerShell | grows with each phase |

## Per-component notes

**vDefend (4a).** Base DFW/GFW is license-key-only — zero infrastructure. Distributed IDS/IPS needs only the Threat Prevention entitlement, no platform. The old NSX Application Platform (NAPP) is **EOL May 31, 2026** — its successor SSP is a self-contained K8s cluster whose smallest viable 2026 form factor runs ~44 vCPU/~152 GB, only justifiable on this host if Security Intelligence is a real goal; Malware Prevention additionally needs per-host SVMs and XL edges — skip on single-host. Terraform `vmware/nsxt` v3.12.0 covers DFW fully and IDPS nearly fully (Beta, NSX ≥4.2.0); the provider `license_keys` argument can apply keys but never removes them — prefer explicit API calls in the module. Order: base key → vDefend key (error 3035 otherwise).

**Avi (8).** Version 31.2.3 (Aug 2026; requires vSphere 8.0U2+ — satisfied) or 32.1.2; 30.2.7 as conservative fallback pending an interop-matrix check for NSX 4.2.4. **NSX-T Cloud connector is the documented mode on OCVS** (Broadcom + a 4-part Oracle Learn series). One Small controller for the lab (a 3-node cluster on one host is 18 vCPU/96 GB for zero real HA). SE mgmt segment needs DHCP; VIPs are advertised as T1 static routes redistributed to T0; internet-facing VIPs use the OCI public-IP-to-private-VIP mapping on the Edge Uplink VLAN. Enterprise is the only supported tier on OCVS. The `vmware/avi` provider is auto-generated per controller release — pin provider = controller version, set `avi_version`, and expect `discovered_networks` diff noise (use `ignore_changes`).

**Aria chain (3–7).** ASL is the deployment engine for everything (no Terraform provider exists for ASL/Aria deployment — the API-driven PowerShell runbook is the industry pattern); `vmware/vra` gives Terraform coverage for Aria Automation day-2 config. Versions per [vcf-bom-5.2.4.md](vcf-bom-5.2.4.md). License via ASL Locker (in-guest keys — avoids touching Oracle-managed vCenter licensing).

**Media staging (2).** Broadcom portal downloads are authenticated; stage binaries (ASL OVA, Aria product bundles ~tens of GB, Avi OVA, NSX/SSP bundles) into the SDDC content library / an `OCVS-LAB-MEDIA`-style datastore path via PowerCLI, keeping the operator-workstation-clean discipline from the predecessor project.

## Single-host resource budget (768 GB)

Oracle-deployed baseline (vCenter, NSX Manager, 2 edges, HCX) ≈ 150–200 GB. Customer additions at lab sizing: ASL + WS1 ≈ 24 GB · Aria Ops (small) + Logs (small) ≈ 48 GB · vRA (single node) ≈ 42 GB · AON (medium) ≈ 44 GB · Avi controller 32 GB + SEs ≈ 8 GB · vDefend DFW/IDPS ≈ 0. **Total ≈ 200 GB on top of baseline — fits with >300 GB headroom.** SSP (+~150 GB) is the one item that strains the budget; defer it. Appliance sizings are typical small-profile figures — confirm each in its install doc at deploy time.
