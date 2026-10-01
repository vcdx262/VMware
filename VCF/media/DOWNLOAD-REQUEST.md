# Download Request — VCF 5.2.4 Lab Media (Path B, rev 2)

*Generated view of `media-manifest.json` (schemaVersion 3, corrections of 2026-08-27 applied). Supersedes the original request and incorporates `DOWNLOADREQUEST-CORRECTED.md` in full.*

> **The portal listing is authoritative for filename, size, and build. If what you see differs from this
> document, stop and report the difference. Do not download a different release to make the document
> right, and do not reject the portal's file to honor the document.** Match items on
> **(product, release, build)** — never on filename. A mismatch is marked `name-differed` with actual
> values recorded; acquisition continues with the remaining items.

## Execution model

- **Stage A0 first — resolve, no downloads**: open each source page below (~10 loads), match every item on (product, release, build), write `resolved-manifest.json` + a diff against `media-manifest.json` to the staging root. Stop for operator review if anything is unmatched or differs.
- **Stage A1 — fetch**: Chrome's download directory must be pre-set to `D:\Claude\Media\vcf-5.2\` (downloads land flat; local verify sorts them later — the stage_to column is not yours to honor). Tick the per-page T&C checkbox (operator-authorized). Download in the order listed below (**ascending size** — a session/permission failure costs bytes, not gigabytes). Record start time per item in `acquisition-state.json`.
- You are not expected to observe completion, hash, or clean up partials — the local Verify stage handles that via `.crdownload` detection and size polling.
- Never record license keys anywhere, and do not open/log the content of `Default_password.txt`.

## Fetch queue (ascending size, 12 files, ≈ 58.6 GB)

| Order | File | Size | Release / build | Source |
|---|---|---|---|---|
| 1 | `Default_password.txt` | 15 B | Avi 31.2.3 / 9158 | servicePk **546119** |
| 2 | `VMware-vRealize-Log-Insight-8.18.7-25423541.pak` | 0.95 GB | Logs 8.18.7 / 25423541 | servicePk **543355** |
| 3 | `VMware-vRealize-Log-Insight-8.18.7.0-25423541.ova` | 1.07 GB | Logs 8.18.7 / 25423541 | servicePk **543355** |
| 4 | `vrlcm-8.18.0-PATCH9.patch` | 1.8 GB | ASL 8.18.0 P9 / 25621957 | patchId **16116** |
| 5 | `CSP-102547-Appliance-3.3.7-Patch.zip` | 1.98 GB | VIDM 3.3.7 / 25163938 | servicePk **203475** (same page as #7, bottom of the file table) |
| 6 | `vRealize-Operations-Manager-Appliance-8.18.7.25423534.ova` | 3.18 GB | Aria Ops 8.18.7 / 25423534 | servicePk **543353** |
| 7 | `identity-manager-3.3.7.0-25163938_OVF10.ova` | 3.39 GB | VIDM 3.3.7 / 25163938 — NOT the 21173100 build | servicePk **203475** |
| 8 | `VMware-Aria-Operations-for-Networks-6.14.3.25416071-collector.ova` | 3.53 GB | AON 6.14.3 / **25416071** | servicePk **543428** |
| 9 | `controller-31.2.3-9158.ova` — OVA only; skip .pkg/.qcow2/.vhd/docker | 4.65 GB | Avi 31.2.3 / 9158 | servicePk **546119** |
| 10 | `VMware-Aria-Operations-for-Networks-6.14.3.25416071-platform.ova` | 7.11 GB | AON 6.14.3 / **25416071** | servicePk **543428** |
| 11 | `vrlcm-vra-8.18.1-8.18.1.37370.patch` — the .patch only; the O11N updaterepo ISO on the same page is NOT wanted | 9.56 GB | vRA 8.18.1 U5 / 37370 | patchId **16081** |
| 12 | `VMware-Aria-Automation-Lifecycle-Installer-24286787.iso` | 21.4 GB | Easy Installer / 24286787 | servicePk **523683** |

**Do NOT download:** `Prelude_VA-8.18.1.36791-24282366_OVF10.ova` (on hold — expected inside #12), the Orchestrator updaterepo ISO on patch page 16081, and nothing from VCF 9.1 / License Hub / SSP / NSX / vSphere / vCenter / HCX listings.

## Source pages

Solution pages: `https://support.broadcom.com/web/ecx/solutiondetails?patchId=16116` · `...?patchId=16081`

Product listings — `https://support.broadcom.com/group/ecx/productfiles?subFamily=<F>&displayGroup=<F>&release=<R>&os=&servicePk=<PK>&language=EN`:

| subFamily / displayGroup | release | servicePk |
|---|---|---|
| `VMware Aria Automation` | 8.18.1 | 523683 |
| `VMware Identity Manager` | 3.3.7 | 203475 |
| `VMware Aria Operations` | 8.18.7 | 543353 |
| `VMware Aria Operations for Logs` | 8.18.7 | 543355 |
| `VMware Aria Operations for Networks` | 6.14.3 | 543428 |
| `VMware Avi Load Balancer` | 31.2.3 | 546119 |

All pages confirmed reachable with enabled download controls on this entitlement (persona: VMware Cloud Foundation; no switch needed).

## Expected checksums (all `portal-verified` — confirm, don't discover)

| File | SHA256 |
|---|---|
| `Default_password.txt` | `dbf923acc107ca3f0180642543e5040aff6fc1336bad285dfd7a3d34fcebd889` |
| `VMware-vRealize-Log-Insight-8.18.7-25423541.pak` | `76bac922d38217151d7f1e404e73729a659b024646c5728f6e4d5c0a31ec733a` |
| `VMware-vRealize-Log-Insight-8.18.7.0-25423541.ova` | `a563be2de4fa22bec13b6ff8151f7b3f0dd363d45039271114bbb82e82038a6d` |
| `vrlcm-8.18.0-PATCH9.patch` | `0a66e891021bb3cecefdd184ec9ecae3b51929f98180e11afad8a3150bb1ec1e` |
| `CSP-102547-Appliance-3.3.7-Patch.zip` | `60d8ba361895d498e0496b2b1f37d8dd651a2cda1a9eca8597c1295f9f8c346e` |
| `vRealize-Operations-Manager-Appliance-8.18.7.25423534.ova` | `45783b25c0edc3dfde27f231fc111ae3724b3cf97f935ffc28d4f88f93c5c9ce` |
| `identity-manager-3.3.7.0-25163938_OVF10.ova` | `0d40cb53a41478c49326b94933558d4bfbe791c56ba67c9d0c8f7b60dce80ab3` |
| `...6.14.3.25416071-collector.ova` | `71772455d9ae34498fed19d65bef7864cf7524173d2e21e95cccfcfba74dabf7` |
| `controller-31.2.3-9158.ova` | `e50d1c6782a84c760c3e6935b3a9ac4e8eb628d44ae53af9bf5b82250b585344` |
| `...6.14.3.25416071-platform.ova` | `a5232daefeb4183c0ab863b55f8208af5f3f1de50f76d5a6293bd50499c3aafa` |
| `vrlcm-vra-8.18.1-8.18.1.37370.patch` | `eb9b2dca754e111efae69a0aad017d5316217c154cc507b5cd9011f70f56e399` |
| `VMware-Aria-Automation-Lifecycle-Installer-24286787.iso` | `10ea86b50c24b94e3bc115a5c58887b9872061a4e18db3d33bb1cd3b680a415c` |

MD5 values are in `media-manifest.json` for legacy-record fallback.

## Report back

Maintain `D:\Claude\Media\vcf-5.2\acquisition-state.json` per item (`pending → resolving → resolved → fetching`, plus `name-differed`/`failed`; the local Verify stage owns `landed`/`verified`). Final `DOWNLOAD-RESULTS.md` is emitted by the Verify stage — your deliverables are the resolved-manifest diff (A0) and the fetch-state updates (A1).
