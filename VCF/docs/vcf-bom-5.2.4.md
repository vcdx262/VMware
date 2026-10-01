# VCF Bill of Materials — OCVS vSphere 8.0U3 stack (VCF 5.2.4)

Verified 2026-08-27 against Broadcom release notes, KB 88287 (flexible BOM), KB 319282 (VCF license keys), KB 426230 (ASL patches), and Oracle OCVS release notes. Two independent adversarial verification passes returned zero corrections. Update this file in the same change that alters any pinned version.

The deployed OCVS "VMware 8.0 update 3" stack maps to **VCF 5.2.4** (build 25437063), with ESXi async-patched to 8.0U3k under the KB 88287 flexible-BOM allowance. OCVS is not a full VCF instance — **no SDDC Manager / Cloud Builder**. Everything above vSphere/vSAN/NSX/vCenter/HCX is customer-deployed via Aria Suite Lifecycle.

## Oracle-managed components

| Component | Version | Build | Notes |
|---|---|---|---|
| ESXi (vSphere 8 Ent+ for CF) | 8.0 Update 3k | 25595708 | OCVS artifact `esxi8u3k-25595708-1`; on KB 88287 flexible-BOM allowlist; carries VMSA-2026-0006 fix |
| vCenter Server 8 Std for CF | 8.0 Update 3k | 25600417 | **Verify live build** — Oracle's June 16, 2026 bundle note ships U3j 25413364; if U3j, patch to U3k customer-side (vCenter must stay ≥ ESXi) |
| vSAN 8 | 8.0U3 (tracks ESXi) | — | No independent version; entitlement 1 TiB/core → 52 TiB on the 52-core BYOL |
| NSX Networking for CF | 4.2.4.0 | 25410638 | VCF 5.2.4 BOM member; 4.2.4.1 (25554964) is an allowed async patch |
| HCX Enterprise for CF | 4.11.5.0 | 25438872 (Cloud) / 25438871 (Connector) | Entitled by VCF sub since 5.1.1, no separate key; upgrades delivered via OCVS SDDC Upgrade feature |

## Customer-deployed components — install in this order (KB 426230)

| # | Component | Version | Build | Notes |
|---|---|---|---|---|
| 1 | Aria Suite Lifecycle | 8.18.0 **Patch 9** | 25621957 | The LCM engine for everything below; cumulative (04 AUG 2026) |
| 2 | Workspace ONE Access | 3.3.7 line (ASL-offered) | — | Identity broker required by Aria Automation |
| 3 | Aria Operations | 8.18.7 | 25423534 | Mandatory for VMSA-2026-0004; use standard vCenter/vSAN/NSX adapters (OCVS mgmt pack is EOGS) |
| 4 | Aria Operations for Logs | 8.18.7 | 25423541 | |
| 5 | Aria Automation (+ Orchestrator) | 8.18.1 + CU5 (KB 437695) | 24282366 GA base | OCVS = standard vCenter + NSX-T cloud accounts |
| 6 | Aria Operations for Networks | 6.14.3 | 25410133 | Final 6.14-line release; OCVS is a documented data source; VCF sub includes Enterprise tier |
| — | Tanzu / Kubernetes | vSphere 8.0U3 Supervisor | — | Enable in vCenter; no separate install |

## NOT covered by the VCF subscription (do not assume)

vDefend Firewall/ATP (own OCVS BYOL software type, per-core) · Avi Load Balancer (own type, per-instance) · VMware Live Recovery / SRM · Data Services Manager (separately-sold advanced service since May 5, 2025) · vSAN capacity beyond 1 TiB/core (separate TiB registration).

## Caveats

- **VCF 9 trap**: Aria Operations 8.18.6/8.18.7 has no permitted upgrade path to VCF Operations 9.0–9.1 (ASL migrates only 8.18.0–8.18.5). Expect redeploy-not-upgrade when OCVS gains VCF 9 (Oracle lists it as future support).
- **Runway**: vSphere 8.x and VCF 5.2 general support end **2027-10-11**; the 8.18 / 6.14 lines are terminal (no 8.19 / 6.15).
- **Before deploying**: confirm the final vRA 8.18.1 × NSX 4.2.4 and vRNI 6.14.3 × NSX 4.2.4 pairs in the Broadcom Product Interoperability Matrix.
- The 52-core VCF BYOL registration covers everything marked customer-deployed above; the SPD explicitly permits deploying Aria capabilities to manage OCVS cores.
