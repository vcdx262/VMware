# Media Handling Specification

Authoritative **process** spec for acquiring, staging, verifying, and delivering install media and license keys. Artifact **identity** (filenames, sizes, builds, hashes, sources) lives only in [`media-manifest.json`](media-manifest.json) — §4 below and [`DOWNLOAD-REQUEST.md`](DOWNLOAD-REQUEST.md) are generated views of it. Reconciled 2026-08-27 against the live portal sweep ([`BROADCOM-ENTITLEMENT-CATALOG.md`](BROADCOM-ENTITLEMENT-CATALOG.md)) and the portal agent's correction record (`DOWNLOADREQUEST-CORRECTED.md`, `DOWNLOAD-PROBLEM-AND-PROPOSAL.md` in the staging root).

## 1. Principles

- The SDDC itself needs no media (ESXi/vCenter/NSX/HCX are Oracle-deployed). Everything above it is covered here.
- The operator/portal agent performs all authenticated downloads; automation never handles Broadcom credentials. The per-page T&C checkbox is operator-authorized.
- Media and license keys never enter git. Keys additionally never enter the manifest, staging tree, state files, or logs.
- **Single source of truth**: every filename, size, build, hash, and source URL exists exactly once, in the manifest, with a `provenance` block. Precedence is absolute and one-directional: `portal-verified` > `doc-derived` > `inferred`. A regeneration that would downgrade a field's state is a build failure. Corrections record the rejected value in `supersedes` so it cannot be re-derived.
- **The portal listing is authoritative** for filename, size, and build. A mismatch with any document is a hard stop that reports (`name-differed`) — never a judgment call, never an instruction to prefer the document. No artifact record may carry prose overriding this rule.
- Artifact matching is on **(product, release, build)** — never on filename.

## 2. Entitlement position (verified live)

All three certification-portal tiles approved, uniform expiry **2027-08-14** (the project's outer bound; tighter than VCF 5.2's 2027-10-11 EoS):

| Tile SKU | Qty | Media | Key | Applied where |
|---|---|---|---|---|
| `VCF-CLD-FND` | 128 cores | ✅ | ✅ | Solution key → ASL Locker + Aria product license pages; vSAN per-TiB key unused on OCVS |
| `ANS-VDEFEND` | 128 cores | — (key only) | ✅ | NSX Manager → System → Licenses (VCF-flavor base key precheck; error 3035 otherwise). No License Hub on the 5.2 stack |
| `ANS-VMW-ALB` | 12 Service Units | ✅ | ✅ | Avi Controller → Administration → Licensing (subscription-native; record embedded expiry) |

Persona **VMware Cloud Foundation** covers everything including Avi. The entitlement also carries full VCF 9.1 — the migration shopping list for when OCVS gains VCF 9 support; irrelevant until then.

## 3. Staging layout

Staging root (local, outside git): `D:\Claude\Media\vcf-5.2\` with subfolders `asl\ ws1\ vra\ aria-ops\ aria-logs\ vrni\ avi\`. Downloads land **flat in the root** (browser limitation); the Verify stage sorts them into subfolders per the manifest's `stage_to`.

## 4. Artifact list *(generated from media-manifest.json v3 — do not hand-edit values here)*

| Id | File | Size | Source | stage_to | Destination |
|---|---|---|---|---|---|
| asl-installer-iso | `VMware-Aria-Automation-Lifecycle-Installer-24286787.iso` | 21.4 GB | Aria Automation 8.18.1 / 523683 | `asl\` | Extract ASL OVA → govc (Path B) |
| asl-patch9 | `vrlcm-8.18.0-PATCH9.patch` | 1.8 GB | patchId 16116 | `asl\` | ASL patch binaries |
| vidm-ova | `identity-manager-3.3.7.0-25163938_OVF10.ova` | 3.39 GB | Identity Manager 3.3.7 / 203475 | `ws1\` | ASL binary repo |
| vidm-csp-patch | `CSP-102547-Appliance-3.3.7-Patch.zip` | 1.98 GB | same product page as vidm-ova | `ws1\` | Insurance |
| vra-cu5-patch | `vrlcm-vra-8.18.1-8.18.1.37370.patch` | 9.56 GB | patchId 16081 | `vra\` | ASL patch binaries |
| ops-ova | `vRealize-Operations-Manager-Appliance-8.18.7.25423534.ova` | 3.18 GB | Aria Operations 8.18.7 / 543353 | `aria-ops\` | ASL binary repo |
| logs-ova | `VMware-vRealize-Log-Insight-8.18.7.0-25423541.ova` | 1.07 GB | Ops for Logs 8.18.7 / 543355 | `aria-logs\` | ASL binary repo |
| logs-pak | `VMware-vRealize-Log-Insight-8.18.7-25423541.pak` | 0.95 GB | same | `aria-logs\` | Optional upgrade path |
| vrni-platform-ova | `VMware-Aria-Operations-for-Networks-6.14.3.25416071-platform.ova` | 7.11 GB | AON 6.14.3 / 543428 | `vrni\` | ASL binary repo |
| vrni-collector-ova | `VMware-Aria-Operations-for-Networks-6.14.3.25416071-collector.ova` | 3.53 GB | same | `vrni\` | ASL binary repo |
| avi-controller-ova | `controller-31.2.3-9158.ova` | 4.65 GB | Avi 31.2.3 / 546119 | `avi\` | govc deploy |
| avi-default-password | `Default_password.txt` | 15 B | same | `avi\` | Controller bootstrap input (credential once read) |

**Total ≈ 58.6 GB.** All 12 hashes are pre-known (`portal-verified`) in the manifest. **On hold:** `Prelude_VA-8.18.1.36791-24282366_OVF10.ova` (14.11 GB) — expected inside the Easy Installer ISO; released from hold only if the extracted inner vRA build ≠ 24282366. **Deferred:** SSP 5.2.0 bundle (~26 GB, phase 9).

## 5. Deliberately NOT downloaded

Avi SE image (controller pushes it to the content library itself) · Orchestrator updaterepo ISO on the CU5 patch page (standalone-vRO only) · ESXi/vCenter/NSX/HCX/SDDC-Manager/Cloud-Builder media (Oracle-deployed) · License Hub 2.0 (VCF 9.1 only) · vDefend (key-only, no media exists) · Avi WAF CRS bundles · anything from VCF 9.1 listings.

## 6. Pipeline stages and automation contract

Execution is split along the capability line: the browser agent can read listings and click downloads but cannot choose destinations, observe completion, or hash; the local shell can do all of that but cannot reach the portal.

| Stage | Actor | Does | Definition of done |
|---|---|---|---|
| **A0 Resolve** | browser agent | Open each manifest source (~10 page loads, no downloads); match on (product, release, build); emit `resolved-manifest.json` + diff vs the manifest | Operator has reviewed the diff; no unmatched artifact, no provenance downgrade. **No byte transfers before this gate.** |
| **A1 Fetch** | browser agent | Chrome download dir pre-set to the staging root; tick T&C; download **smallest-first** (15 B password file first, 21.4 GB ISO last); record start times | All items clicked through; failures recorded per item |
| **B Verify** | local shell | Completion = no `<name>.crdownload` sibling AND size stable across two polls ≥30 s apart AND size ≈ manifest bytes. Then sort files into `stage_to` subfolders, hash (detached `nohup`/background job for multi-GB files — shell call timeouts are shorter than a 21 GB hash), compare to manifest, update `acquisition-state.json`, emit `DOWNLOAD-RESULTS.md` | Every file `verified` in the state file; zero hash mismatches |
| **C Transfer** | `scripts/Publish-Media.ps1` (planned) | Resumable multipart upload to an OCI Object Storage bucket (`us-sanjose-1`); PAR URL manifest to state, not git | Bucket objects match checksums |
| **D Deliver** | Substrate/ASL modules | SDDC-side pull via PARs: OVAs → content library/datastore; product OVAs + patches → ASL `/data` + Binary Mapping API | Destinations report expected version/build; PARs expired/revoked |

`acquisition-state.json` (staging root) tracks each item through `pending → resolving → resolved → fetching → landed → verified` (or `name-differed` / `hash-mismatch` / `failed`), with attempts and timestamps; a re-run skips `verified` items. This is what makes a 58.6 GB job survive an interrupted session.

Rules: A0 gates A1; B passes before C; D consumes only bucket objects; every stage idempotent; no stage logs a license key or the Avi default password's content.

## 7. Known caveats

1. **Aria licensing on OCVS**: the vCenter carries Oracle's key, so VCF auto-entitlement never fires. Aria Ops accepts the VCF solution key directly; vRA takes it via ASL Locker; Logs takes direct key entry; **AON may reject manual keys** (documented KB behavior) — use its 60-day eval and never re-license the Oracle-managed vCenter.
2. **Portal automation hazards** (full list in the catalog §0): broken View Group controls (use groupId URLs), slow SPA pages (3–5 s waits, re-locate elements), group pages landing on newest patch level, patch records filed under base releases.
3. Eval clocks as buffers if a key misbehaves: AON 60 days, Logs 90 days, Avi Enterprise-equivalent eval.

## 8. Acceptance gates

Media handling is complete when: (a) no manifest item remains at `provenance.state = inferred` at A1 start; (b) the A0 diff was emitted and operator-cleared; (c) every landed file's computed SHA256 equals the manifest value; (d) `acquisition-state.json` shows `verified` for all 12 files and `DOWNLOAD-RESULTS.md` has zero `hash-mismatch` rows; (e) no `.crdownload` files remain under the staging root; (f) destination (content-library item / ASL binary mapping) reports the expected version/build; (g) keys are in the password manager with the 2027-08-14 expiry recorded; (h) no media or key material in git status.
