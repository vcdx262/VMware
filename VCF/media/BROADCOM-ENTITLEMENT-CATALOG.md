# Broadcom Portal — Download Entitlement Catalog

Machine-oriented inventory of what this account can actually download, captured live from
`support.broadcom.com` on **2026-08-27**. Scope: the VCF subscription bundle families. Written to be
consumed by an automation agent, so URL construction rules and portal defects are documented alongside
the data.

Account persona: **VMware Cloud Foundation**. Entitlement source: VCP-VCF certification licenses
(no corporate site ID). Every file listed below showed an **enabled** (blue) download control —
nothing in scope is entitlement-locked.

---

## 0. How to reach any file (read this first)

### 0.1 Three URL shapes

**Family index** — lists display groups and their releases:
```
https://support.broadcom.com/group/ecx/productdownloads?subfamily=<FAMILY>
```

**Release file listing** — the normal case:
```
https://support.broadcom.com/group/ecx/productfiles
  ?subFamily=<FAMILY>
  &displayGroup=<DISPLAY_GROUP>
  &release=<RELEASE>
  &os=
  &servicePk=<SERVICE_PK>
  &language=EN
```

**Patch / solution detail** — for anything ASL applies as a patch:
```
https://support.broadcom.com/web/ecx/solutiondetails?patchId=<PATCH_ID>
```

### 0.2 The `groupId` problem — critical for VCF 9.x and vSphere 8.x

Some release pages are **not** file tables. They are indexes of component groups fronted by a
"View Group" control. That control is **broken portal-wide**: it renders as
`<a class="primary links">View Group</a>` with no `href`, no data attributes, and no working click
handler. Clicking fires no network request and expands nothing. Confirmed broken on both
VMware Cloud Foundation 9.1 and vSphere Foundation 9.1.

The `groupId` values exist **only in the page's Redux store**, not in the DOM or accessibility tree:

```js
state.productFiles.packlistDetailsList   // fields: description, release, groupId, packlistId
```

`groupId === packlistId` in every case observed. Once you have the id, append it to the release URL:

```
…&servicePk=<SERVICE_PK>&language=EN&groupId=<GROUP_ID>
```

**Do not build automation that clicks "View Group."** Read the Redux store, or use the groupId tables
in §4 and §5 below, which are already harvested.

### 0.3 Other portal behaviours to code around

| Behaviour | Handling |
|---|---|
| Pages are slow SPAs | Wait 3–5s after navigation before reading |
| Display-group rows are `role=tab` elements; a second click re-collapses | Click exactly once; if the `tab` ignores the click, click its inner text node |
| Rotating notice banner remaps element refs between calls | Re-locate elements after every wait |
| Family "Solutions" tab button ignores clicks | Use `?subfamily=<FAMILY>&tab=Solutions` on the productdownloads URL |
| Secondary tabs (Open Source, OEM Addons, Custom ISOs, Additional-Downloads) often render greyed and inert | Treat absence of content as a portal defect, not as missing entitlement |
| Group pages open on the **newest patch level**, not the release named in the index | An index row saying "9.1.0.0" may land you on 9.1.0.0400 — assert the release you got |
| Legacy solution records (pre-2024) publish MD5 only, no SHA256 | Manifest schema must allow a null SHA256 |
| Download is gated by an "I agree to the Terms and Conditions" checkbox | Per-page, must be ticked by the operator before the download control works |

### 0.4 Checksums

Every current file listing publishes **both SHA256 and MD5**. There is no need for a separate
"capture checksums at download time" step — seed the manifest from this document and verify after.

---

## 1. Entitlement summary — 27 families

**In scope (VCF subscription bundle), catalogued below:**

| Family (exact `subfamily` string) | Status |
|---|---|
| `VMware Cloud Foundation` | ✅ VCF 9.1.0.0 + legacy through 4.5.2 |
| `VMware vSphere Foundation` | ✅ 9.1.0.0 (groupIds shared with VCF 9.1) |
| `VMware vSphere` | ✅ 8 editions, 8.0 / 7.0 / 6.7 |
| `VMware vCenter Server` | ✅ 9.1.0.0300 + 8.x train |
| `VMware vSAN` | ⚠️ index only — ships inside ESX image |
| `VMware NSX` | ✅ 4.2.4.1 down to 4.0.0.1 |
| `VMware NSX-T Data Center` | ✅ 3.2.4.3 down to 3.2.0.1 |
| `VMware HCX` | ✅ 4.11.5 |
| `VMware Firewall` (vDefend) | ✅ SSP 5.2.0, License Hub 2.0, conversion tool |
| `VMware Avi Load Balancer` | ✅ 32.1.2 newest; 38 releases total |
| `vSphere Supervisor Services` | ✅ 13 service groups |
| `VMware Aria Automation` | ✅ 8.18.1 + Orchestrator + 40+ patch records |
| `VMware Aria Operations` | ✅ 8.18.7 + 19 patch records |
| `VMware Aria Operations for Logs` | ✅ 8.18.7 + patch records |
| `VMware Aria Operations for Networks` | ✅ 6.14.3 + patch records |
| `VMware Identity Manager` | ✅ 3.3.7 |
| `VMware Aria Suite` | ⚠️ 2019 manifest only, no files of its own |
| `VMware vRealize Network Insight` | ❌ Products tab empty |

**Entitled but out of scope** (you have rights, not catalogued here): `Flings`,
`Tanzu Mission Control (Self-Managed)`, `VMware Antrea`, `VMware Harbor Registry`,
`VMware Cloud Director`, `VMware Cloud Director Container Service Extension`,
`VMware Cloud Director Encryption Management`,
`VMware Cloud Director Extension for VMware Data Solutions`,
`VMware Cloud Director Object Storage Extension`.

---

## 2. Strategic finding — you are entitled to VCF 9.1, not just 5.2

Your media spec targets **VCF 5.2 + Aria 8.18**. The portal offers **VCF 9.1.0.0** on the same
entitlement, and in 9.x the Aria products are renamed and restructured:

| 8.18-era product | 9.1 equivalent | 9.1 groupId |
|---|---|---|
| Aria Suite Lifecycle | *(absorbed into SDDC Lifecycle / Fleet Lifecycle)* | 540659 / 540662 |
| Aria Automation | VCF Automation | 540511 |
| Aria Operations | VCF Operations | 540531 |
| Aria Operations for Logs | Log management | 540589 |
| Aria Operations for Networks | VCF Operations for networks | 540655 |
| Aria Automation Orchestrator | VCF Operations orchestrator | 540654 |
| VMware Identity Manager | Identity broker | 540590 |
| HCX | VCF Operations HCX | 540652 |

**This matters for your two license keys.** The portal is now banner-messaging that VCF 9.1 customers
using vDefend Firewall, vDefend SSP, or Avi Load Balancer must go through **License Hub 2.0**.
The License Hub appliance is a download in its own right:

- `License-Hub-2.0.0.0.0.25630952.ova` — 11.04 GB, SHA256 `b5f1c1ba793c89fad725a4a6a3fdd24cf6c7ac73a5179f15724cb9ffe4b8052d`, MD5 `60b8bfd0bf31e30757ca38324c5f7d75`
- Reachable from **both** the `VMware Firewall` family (groupId 545580) and the Avi 32.1.2 file list

If the automation targets 9.1, License Hub is a prerequisite for applying the vDefend and Avi keys.
On 5.2 it is not.

---

## 3. Ready-to-deploy note: ASL 8.18 has no standalone installer

Carried over from the earlier spec reconciliation and re-confirmed here:
`VMware-Aria-Suite-Lifecycle-Installer-24029606.iso` does not exist on this entitlement.
`VMware Aria Suite` (2019) is a manifest of View-Group pointers, one of which is
*VMware Aria Suite Lifecycle, Release FAM-VRSLCM, Release Level Info 204011* — but the View-Group
control is the broken one described in §0.2, so it is only reachable by constructing
`&groupId=204011` by hand. **Worth one attempt before falling back** to the 21.4 GB
`VMware-Aria-Automation-Lifecycle-Installer-24286787.iso` under Aria Automation 8.18.1.

Other View-Group pointers inside the Aria Suite 2019 manifest, same treatment:

| Component | Release | groupId |
|---|---|---|
| VMware Aria Suite Lifecycle | FAM-VRSLCM | 204011 |
| VMware Aria Operations for Networks | FAM-VRNI | 204303 |
| VMware Aria Automation Config (SaltStack) | FAM-VRA-SALTSTACK | 204010 |
| VMware Aria Automation Orchestrator | FAM-VR-OVA | 204009 |
| VMware Aria Operations | FAM-VR-OPS | 204008 |
| VMware Aria Automation | FAM-VCAC | 204007 |
| VMware Aria Operations for Logs | FAM-VC-LOG-INSIGHT | 204006 |
| VMware Identity Manager 3.3.7 | 3.3.7 | 203475 |

---

## 4. VMware Cloud Foundation

`subfamily=VMware Cloud Foundation`

**Display group `VMware Cloud Foundation 9`:** 9.1.0.0 (**540528**), 9.0.2.0 (537791), 9.0.1.0 (534266), 9.0.0.0 (529536)

**Display group `Legacy VMware Cloud Foundation Versions`:** 5.2.4.0 (**544035**), 5.2.3 (540472), 5.2.2 (534268), 5.2.1.1 (528885), 5.2.1 (523724), 5.2 (520823), 5.1.1 (208634), 5.1 (203383), 5.0 (203382), 4.5.2 (203381)

### 4.1 VCF 5.2.4.0 (servicePk 544035) — flat file table

| File | Size | Build | SHA256 | MD5 |
|---|---|---|---|---|
| `VMware-Cloud-Builder-5.2.4.0-25437063_OVF10.ova` | 31.19 GB | 25437063 | `f9c370f50c6523a75a98196d681252e7e9a33157326dac90492d7cbbbafb1a14` | `b89fe5e99a6c07384f154ca5ffeb3da5` |
| `vcf-ems-deployment-parameter.xlsx` | 85.52 KB | 25435484 | `3bb798b2aa04da588cf4b1152ac6f3b60f6ce9ca0557a2f1fa72184e418a916e` | `af1cf740510c74a3316228976e3fd201` |
| `vcf-vxrail-deployment-parameter.xlsx` | 77.17 KB | — | `2726621ea22375102d410e63a72938ceffee475a0e785293fbaf3443877b8dff` | `a6c0836c7321a2118a8e5fa6b754cab0` |
| `VCF524_CVE_STATUS_2026-08-20.csv` | 1.14 MB | — | `157c4ca72f2d0559fa9cd949179b825c804fcfac7c9cc85cb0074de226f3c884` | `bd4fd7c3fade508e1f6c261540241c68` |

### 4.2 VCF 9.1.0.0 (servicePk 540528) — 43 component groups

Base URL for all rows:
`…/productfiles?subFamily=VMware Cloud Foundation&displayGroup=VMware Cloud Foundation 9&release=9.1.0.0&os=&servicePk=540528&language=EN&groupId=<ID>`

| Component group | Version | groupId |
|---|---|---|
| VCF Installer | Latest | 540530 |
| VMware ESX | 9.1.0.0 | 540591 |
| VMware ESX on Arm | 9.1.0.0 | 540712 |
| VMware vCenter | 9.1.0.0 | 540509 |
| VMware vSAN | 9.1.0.0 | 540510 |
| VMware NSX | 9.1.0.0 | 540588 |
| VMware vSphere Supervisor | 9.1.0.0 | 540634 |
| VMware Avi Load Balancer | 32.1.1 | 542813 |
| VCF Automation | 9.1.0.0 | 540511 |
| VCF Operations | 9.1.0.0 | 540531 |
| VCF Operations HCX | 9.1.0.0 | 540652 |
| VCF Operations for networks | 9.1.0.0 | 540655 |
| VCF Operations orchestrator | 9.1.0.0 | 540654 |
| Identity broker | 9.1.0.0 | 540590 |
| Log management | 9.1.0.0 | 540589 |
| SDDC Lifecycle | 9.1.0.0 | 540659 |
| Fleet Lifecycle | 9.1.0.0 | 540662 |
| Software Depot | 9.1.0.0 | 540638 |
| License server | 9.1.0.0 | 540639 |
| Cloud proxy | 9.1.0.0 | 540587 |
| Protection and Recovery (vSphere Replication, vSAN Snapshots) | 9.1.0.0 | 539713 |
| Real-time metrics | 9.1.0.0 | 540661 |
| Real-time metrics store | 9.1.0.0 | 540611 |
| Salt RaaS | 9.1.0.0 | 540678 |
| Salt master | 9.1.0.0 | 540693 |
| Telemetry | 9.1.0.0 | 541495 |
| VCF Consumption CLI | 9.1.0.0 | 540529 |
| VCF Consumption CLI Plugins | 9.1.0.0 | 540672 |
| VCF service - Configuration | 9.1.0.0 | 540663 |
| VCF service - Data Services Manager | 9.1.0.0 | 540633 |
| VCF service - Encryption Management | 9.1.0.0 | 540658 |
| VCF service - Harbor | 9.1.0.0 | 540694 |
| VCF service - Metrics Aggregator | 9.1.0.0 | 540675 |
| VCF service - Migration | 9.1.0.0 | 540637 |
| VCF service - Migration service engine | 9.1.0.0 | 540660 |
| VCF service - Secret Store | 9.1.0.0 | 541440 |
| VCF service - VKS Cluster Management Auto-Attach | 9.1.0.0 | 540635 |
| VCF services runtime | 9.1.0.0 | 540674 |
| VKSM Extensions | 9.1.0.0 | 540610 |
| VMware Deep Learning VM Image | 9.1.0.0 | 540657 |
| VMware Guest Customization Engine for Instant Clone | 13.2.1.0 | 541369 |
| VMware Remote Console | 13.1.0.0 | 540653 |
| VMware Tools | 13.1.0.0 | 540632 |

### 4.3 VCF 9.1 core group file listings

**VCF Installer** (540530) → release 9.1.0.0400

| File | Size | Build | SHA256 | MD5 |
|---|---|---|---|---|
| `VCF-SDDC-Manager-Appliance-9.1.0.0400.25570100.ova` | 2.28 GB | 25570100 | `5fde2adad133a89ea7f6a64fa36e9958f1f3abe9038af38cf4646f6d353c3c2a` | `105e980b3624ed1be69b5799d103021a` |
| `VCF-SDDC-Manager-Appliance-Upgrade-9.1.0.0400.25570100.tar` | 2.41 GB | 25570100 | `d6e14c298e42353206131c29e1aa21499fddb7fcb8bf80bd3841545fe2c65b1d` | `a6e04934a4ddeca0583b06b300e6c0f5` |

**VMware ESX** (540591) → release 9.1.0.0200, level 544962

| File | Size | Build | SHA256 | MD5 |
|---|---|---|---|---|
| `VMware-VMvisor-Installer-9.1.0.0200.25557999.x86_64.iso` | 692.03 MB | 25557999 | `a4e2b45c9438d6134ba7226b978cbabda0b75670c623c805ad60c81392f35e3f` | `fe6a4ff8b4d6e73bc3113ad33725377f` |
| `VMware-ESXi-9.1.0.0200.25557999-depot.zip` | 672.7 MB | 25557999 | `d3e21e885f59282598f1ba5b7a550741037f67f048fb28a439cd6b8b8c139272` | `2df3ee07215d665b53d7efcde8df0064` |

**VMware vSAN** (540510) — **no distinct artifacts.** The panel renders VMware ESX (level 544962)
with byte-identical files. vSAN ships inside the ESX image on 9.x.

**VMware vCenter** (540509) → release 9.1.0.0300, level 545592

| File | Size | Build | SHA256 | MD5 |
|---|---|---|---|---|
| `VMware-VCSA-all-9.1.0.0300.25629530.iso` | 11.97 GB | 25629530 | `7e9305c5bbb114f4e7ddcb2be68207d64230f18f52cdbcd6c9f1ba6009cfb52c` | `7cda5344cb60cde9504fb49ec1a4a266` |
| `VMware-vCenter-Server-Appliance-9.1.0.0300.25629530-updaterepo.zip` | 8.39 GB | 25629530 | `a492b8f9d1998693132ce95438d5472132cec55b2dd3f4a4f6bfe06dd6948dfe` | `89870254baaf8c2ba8c6449330af3043` |
| `VMware-vCenter-Server-Appliance-9.1.0.0300.25629530-patch-FP.iso` | 8.04 GB | 25629530 | `759a55bd4c0029503c61814bf5f61f73e54fa07339915d6f0107150f868b5f2f` | `7dd0a330079ec4a11542bf8355c990a7` |

**VMware NSX** (540588) → release 9.1.0.0200, build 25524170

| File | Size | SHA256 | MD5 |
|---|---|---|---|
| `nsx-unified-appliance-9.1.0.0200.25524172.ova` | 7.53 GB | `6a341f140921ef02b12e1332719222b7858bdaa561a274da31a89df074274a81` | `6890230a5d832fc580ad5d97a7555a8f` |
| `VMware-NSX-upgrade-bundle-9.1.0.0200.0.25524170.mub` | 5.57 GB | `35e0f41ed2ee68d61ba96ce309ed452b31791e7741fd36ba5a5617b6f5223230` | `a8b093f335dc856cb70db404afac2339` |
| `VMware-NSX-upgrade-bundle-9.1.0.0200.0.25524170-pre-check.pub` | 828.76 MB | `29d229a575830375a2ff988402ea7371c35d0e77eccfba04d4a0a99f4707c395` | `b110e8854a046eb98a0f15e62dc4e76f` |
| `nsx-edge-9.1.0.0200.25524173.iso` | 2.78 GB | `17b0bec9b8c449a43ca239c7757fe93f25c404a398f701ccf8e909bdcaa85205` | `a446b35775e76271b27a1482e54549fc` |
| `nsx-edge-9.1.0.0200.25524173.ova` | 2.23 GB | `52d0e2771605fcec2b62b4482688a3a2ffe4f07db886dcd149ed2c808a550a12` | `e1e76eaeaedb28d0d39124213c214059` |
| `VMware-NSX-edge-9.1.0.0200.25524173.nub` | 1.99 GB | `f575aa301d1b5e70c559d2d6b5ec880cb8655df56478f0406363bae6580dfb39` | `f454aca8859d588dafa64ac62f63420e` |

⚠️ The "Autonomous Edge L2VPN Client" row is the **same artifact** as `nsx-edge-…ova` — identical
hashes, filename differs only by a stray double hyphen. Deduplicate by hash, not by name.

**VMware Avi Load Balancer** (542813) → 32.1.1 only

| File | Size | Build | SHA256 | MD5 |
|---|---|---|---|---|
| `controller-32.1.1-9129.ova` | 3.8 GB | 25377988 | `9128d87ef778f6ce231659fc3e7c7fcfa5667689a929db6513ac9275a7fed453` | `ea705d783c4a606dab2c47b8a1486f02` |

**VCF Operations** (540531) → release 9.1.0.0400, level 544432

| File | Size | Build | SHA256 | MD5 |
|---|---|---|---|---|
| `Operations-Appliance-9.1.0.0400.25541561.ova` | 3.07 GB | 25541561 | `ea23bdd7fa7331a9654258279ef613e3ac98d78a8abd3dcbcbf3dd1dd95e2af8` | `d5993c230f1c911067a49ddb9c77686f` |
| `Operations-Upgrade-9.1.0.0400.25541550.pak` | 6.23 GB | 25541550 | `411595ca2986f9a9120ac3aff927fe67e859157ab8fc4ddfd33953cf2cbca360` | `55b8378fbfd811eb9b620bcbd597b346` |
| `VMware_Cloud_Foundation_Operations-9.1.0.0400.25541550-upgrade-manifest.json` | 847 B | 25541550 | `653443f1f50b4a8767e0dbce71c261f72099c2b1938914ec3816934c388f86f4` | `e3e2c4fbe970d45b89876329978e719d` |

**VCF Automation** (540511) → release 9.1.0.0200, level 544439

| File | Size | Build | SHA256 | MD5 |
|---|---|---|---|---|
| `vcfa-bundle-9.1.0.0200.25556825.tar` | 14.95 GB | 25556825 | `529e82b45be965b78405f97a540b91fdaef23271b6c1790d119932cebebd3270` | `e756725d451e8e110926bad820200e46` |
| `vcfa-plugin-9.1.0.0200.25556825.tgz` | 119.63 KB | 25556825 | `b45da50cc2cf62510154a33b50b407825ca3db7d6e3009b8bc5311f35487b40c` | `1e56b3400dd112ed7aba5b0376f6ecfc` |
| `depot-manifest-vcfa-bundle-9.1.0.0200.25556825.yaml` | 727 B | 25556825 | `851e304a5834a6e90a965f5a243139a8aa119834d6efd08ac7e1ab6fd83427f2` | `e8f6f693f65ed8fae27807831768749f` |
| `configuration-schema-vcfa-bundle-9.1.0.0200.25556825.yaml` | 3.75 KB | 25556825 | `35db1cf71f8d0733e925f869e8e8e2d00b517d1d28e63fc0c2fab96422cefc24` | `126073870258e8c8b76d5401db57f8f4` |

---

## 5. VMware vSphere Foundation

`subfamily=VMware vSphere Foundation` · display group `VMware vSphere Foundation 9`
Releases: 9.1.0.0 (**542815**), 9.0.2.0 (537838), 9.0.1.0 (534207), 9.0.0.0 (529507)

**VSF 9.1 is a strict subset of VCF 9.1 — 26 of the 43 groups, and every `groupId` is identical.**
Reuse the §4.2 table; VSF omits: VCF Automation, Identity broker, Real-time metrics, Real-time metrics
store, Salt RaaS, Salt master, VCF Operations HCX, VCF Operations for networks, VMware NSX, VMware Deep
Learning VM Image, VKSM Extensions, and the Data Services Manager / Metrics Aggregator / Migration /
Migration service engine / Secret Store / VKS Auto-Attach services.

Verified URL shape:
`…/productfiles?subFamily=VMware vSphere Foundation&displayGroup=VMware vSphere Foundation 9&release=9.1.0.0&os=&servicePk=542815&language=EN&groupId=540591`

---

## 6. vSphere 8.x / 7.x (classic)

### 6.1 `VMware vSphere` — 8 editions

| Edition (display group) | Releases (servicePk) |
|---|---|
| Enterprise Plus | 8.0 (202628), 7.0 (202621), 6.7 (202613) |
| Enterprise | 8.0 (202627), 7.0 (202620) |
| Standard | 8.0 (202631), 7.0 (202624) |
| Essentials Plus | 8.0 (202630), 7.0 (202623) |
| Essentials | 8.0 (202629), 7.0 (202622) |
| Desktop | 8.0 (202626), 7.0 (202619) |
| vSphere Scale-Out | 8.0 (202633), 7.0 (202625) |
| vSphere ROBO | 8.0 (202632) |

Each 8.0 edition page is a component index (same `groupId` mechanics as §0.2). Component groups at 8.0:

| Component | groupId |
|---|---|
| vSphere Hypervisor (ESXi) 8 | 204419 |
| vCenter Server 8 | 204421 |
| NSX-T | 204420 |
| VMware Tools | 204422 |
| vSphere Replication | 204423 |
| Aria Automation Orchestrator (OVA) | 204424 |
| vSphere Bitfusion | 204418 |

Edition differences: Enterprise Plus has all 7. Enterprise / Desktop / Standard drop Bitfusion.
Essentials Plus drops Orchestrator too. Scale-Out drops vSphere Replication. Essentials keeps only
Tools / vCenter / NSX / ESXi. ROBO keeps Tools / vCenter / ESXi.

**ESXi 8 (groupId 204419) → defaults to 8.0U3, level 520489.** Also selectable: 8.0U2b, 8.0U2, 8.0U1a, 8.0U1, 8.0b, 8.0.0.

| File | Size | Build | SHA256 | MD5 |
|---|---|---|---|---|
| `VMware-VMvisor-Installer-8.0U3-24022510.x86_64.iso` | 605.63 MB | 24022510 | `05ce214069a3e23265881fbd7a949fb93a99aa13059c6cac31920196e97ba4a1` | `3697929d94704ac495247cd3fcf1c4eb` |
| `VMware-ESXi-8.0U3-24022510-depot.zip` | 599 MB | 24022510 | `82e963b196c9fca6ae2e25de2bfd353e221bf86f041f561b3ef42815e90eb604` | `e63142b375a1236e2b1500c5c3b1312e` |

### 6.2 `VMware vCenter Server`

**Display group `VMware vCenter Server Standard`:** 9.1.0.0300 (**545592**), 9.1.0.0200 (544964), 9.1.0.0100 (543388), 9.0.2.0100 (545591), 9.0.2.0 (537851), 9.0.1.0 (534284), 9.0.0.0 (529540)

**Display group `VMware vCenter Server 8.x`:** 8.0U3 (**520490**), 8.0U2c (208631), 8.0U2b (208630), 8.0U2a (203308), 8.0U2 (203307), 8.0U1d (203306), 8.0U1c (203305), 8.0U1b (203304), 8.0U1a (203303), 8.0U1 (203302), 8.0.0c (203301), 8.0.0b (203300), 8.0.0a (203299), 8.0.0 (203298)

**8.0U3 (520490):**

| File | Size | Build | SHA256 | MD5 |
|---|---|---|---|---|
| `VMware-VCSA-all-8.0.3-24022515.iso` | 10.8 GB | 24022515 | `645fb3debfe33331fed5ffd9971d5286b070f412b56a523a78abdc7bece07e29` | `044343943d7c0fd1982ac7fd0b30e310` |
| `VMware-vCenter-Server-Appliance-8.0.3.00000-24022515-updaterepo.zip` | 8.16 GB | 24022515 | `7d8b2407731415e04cacc434c166c6eaeae5e47d108562562ed0855ece3543b6` | `aaac11aad47484ded3eea6676283f684` |
| `VMware-vCenter-Server-Appliance-8.0.3.00000-24022515-patch-FP.iso` | 7.92 GB | 24022515 | `f611bba1fca57bfc81a021b0de2433a1df284b5283e0750f49eb2272fdd908ed` | `d8a092d5c0f8c047a12f2a4142834c2b` |
| `VMware-vSphere_Replication-9.0.1-24037980.iso` | 2.54 GB | 24037980 | `d68d5490c9113d75ced6adc26e9d40daa4dae1617571d6c4a3d4874315b70939` | `e050d18b399addb2c1cebe65de074315` |

**8.0U3 "Drivers & Tools"** (servicePk per group): VMware Bootstrap Appliance Latest (546050),
VMware Remote Console 12.0.5 (207973) / 12.0.4 (207972), Plug-Ins for vSphere Replication 9.0.1
(520281), vSphere Client SDK 8.0U3 (521589), vSphere Management SDK 8.0U3 (521163),
Skyline Health Diagnostics 5.1.1 (521085), OVF Tool 4.6.3 (521544).

### 6.3 `VMware vSAN`

Single display group, single release **8.0 (202590)**. Carries no files — it is a pointer page to
vCenter 8 (groupId 204382) and ESXi 8 (groupId 204381), which resolve to the same artifacts as §6.1/§6.2.

---

## 7. NSX

### 7.1 `VMware NSX`

Releases: 4.2.4.1 (**545490**), 4.2.4.0 (543579), 4.2.3.3 (539437), 4.2.3.2 (538099), 4.2.3.1 (535469), 4.2.3.0 (532466), 4.2.2.2 (535526), 4.2.2.1 (532112), 4.2.2.0 (531224), 4.2.1.4 (531686), 4.2.1.3 (528021), 4.2.1.2 (527120), 4.2.1.1 (526309), 4.2.1.0 (523227), 4.2.0.2 (523863), 4.2.0.1 (523084), 4.2.0.0 (521507), 4.1.2.7 (535295), 4.1.2.6 (531418), 4.1.2.5 (521940), 4.1.2.4 (520394), 4.1.2.3 (208581), 4.1.2.1 (202933), 4.1.2.0 (202930), 4.1.1.1 (523788), 4.1.1.0 (202927), 4.1.0.2 (202924), 4.0.1.1 (202921), 4.0.0.1 (202919)

**4.2.4.1 (545490), build 25554964 — primary artifacts:**

| File | Size | SHA256 | MD5 |
|---|---|---|---|
| `nsx-unified-appliance-4.2.4.1.0.25554968.ova` | 11.84 GB | `7ebc4a9b7f23e3f3cfa994507e7c21790b93c503ddfbb9b710c06639958d627b` | `4e236df54e588730318da85ecf864e03` |
| `nsx-embedded-unified-appliance-4.2.4.1.0.25554968.ova` | 11.84 GB | `726832c5cb40709402bd075687cf6540a2d8d8ee2faa087c9b8f329946ce30dc` | `da6f616d7a7dfe6f2052a31402d8580f` |
| `nsx-edge-4.2.4.1.0.25554970.ova` | 3.47 GB | `818f853c849de5a4802561b0f3b7b64f4dfc7c852743c08f29f3e45f8eaf06c7` | `2d8e2fe21b90045da8cbba89176c37bf` |
| `nsx-edge-4.2.4.1.0.25554970.iso` | 4.26 GB | `c0906e24d82bfa055fa999066bc8b0e26e7b493c299d0a6e8c4a289ac5144a47` | `6b0df0f375de6aeea55bc01d1a682561` |
| `VMware-NSX-edge-4.2.4.1.0.25554970.nub` | 3.08 GB | `46e1447889448bde789070bf0a639490429ab3b3c91750055cc909851211f997` | `84d06bb6e7f3994c881f25e0c60054e1` |
| `VMware-NSX-upgrade-bundle-4.2.4.1.0.25554964.mub` | 9.26 GB | `1a7db5ad1b7c95ce45826373360c3d2b2b666e0572e9460c2429cb5ee0a430bd` | `cd4fcb7f6abd4c1cc4571c1dd90f0ee9` |
| `VMware-NSX-upgrade-bundle-4.2.4.1.0.25554964-pre-check.pub` | 845.89 MB | `af9e3463644d47e722ecf83aca9e5ff19018de2fc49dc1e7faa128583dee502b` | `418fa6943e31974e1fe4044d00397d1b` |
| `nsx-lcp-esxio-4.2.4.1.0.25554966-esx80-unified.zip` | 181.64 MB | `b50c46a6fbb98e43f9a9e28f62ffc19ae90eb4a1f9da443b8c7c05c1fcce1d77` | `36ac338c3ea92d045583fe3ff6c882cd` |
| `nsx-lcp-4.2.4.1.0.25554966-esx70.zip` | 66.84 MB | `33129177f76017754917afbb5cf1d752706c2ed31e1584c57d306a3393b8900e` | `e2afc7af17605193e31b35f0d6c2134d` |
| `VMware-NSX-T-4.2.4.1.0.25554968.vlcp` | 291.98 KB | `a59ddb021763161ed4b3cb3bb63f0411898720d678824e8a025abe36bda24a5b` | `9ab6cac6f189adfb8fa037f8ac4db276` |
| `compatibility-matrix.tgz` | 1.05 KB | `55a820f93830e17aa9bbec189a882ef7e676bb62ece8643303410c7cc149bae1` | `074022e73a314998eed076bd3de69275` |

Plus 14 bare-metal LCP bundles (RHEL 7.6–8.6, SLES 12 SP3/4/5, Ubuntu xenial/bionic/focal, Win32 vs2017).
**Drivers & Tools:** NSX Splunk App 4.2.4.1 (545491) — `nsx_splunk_app.spl`, 13.09 MB, SHA256 `cf423683d0d538c9172bcebfcc11c8c50693d3bbcc776ba50204c5bcd0e94a19`, MD5 `5995e2477dd73b63466ebeecfc6ac37f`.

### 7.2 `VMware NSX-T Data Center`

Releases: 3.2.4.3 (**534934**), 3.2.4.2 (533389), 3.2.4.1 (524217), 3.2.4.0 (208584), 3.2.3.2 (202980), 3.2.3.1 (202977), 3.2.3 (202974), 3.2.2.1 (202971), 3.2.2 (202968), 3.2.1.2 (202965), 3.2.1.1 (202963), 3.2.1 (202960), 3.2.0.1 (202958)

**3.2.4.3 (534934), build 24942842 — primary artifacts:**

| File | Size | SHA256 | MD5 |
|---|---|---|---|
| `nsx-unified-appliance-3.2.4.3.0.24942847.ova` | 10.43 GB | `8bd938b849e83493dc690e17baf1650b8de785fa22bad50262ff2f588360a017` | `ea45548796d18d5981b569ab1b429aa2` |
| `nsx-embedded-unified-appliance-3.2.4.3.0.24942847.ova` | 10.43 GB | `6548bc8cbfe41382e6b4331254fb83844e38d8b9f682701a11876b47527bf4d9` | `8c7d13ff4fbfe692a6a4b6471e588197` |
| `nsx-edge-3.2.4.3.0.24942852.ova` | 2.79 GB | `701bfa9bda085bbd14fd3147050fdc2b75416bbbacb3fb838332254146dabdf5` | `13b51c3b4527c71694a9b54d79181ebe` |
| `nsx-edge-3.2.4.3.0.24942852.iso` | 2.46 GB | `03943d8b28bc6e8107806f63ff74838ea874552ce6f7500035a6b883495d3d3f` | `dc0d4d0e608e075f1f79ceb9e6834468` |
| `nsx-svm-appliance-3.2.4.3.0.24942843.ova` | 1.35 GB | `0bdc066b62c00ad8561523fec148887d5f7b92dff1c53e7bd4f351d21c3f0eee` | `041a819fa876013d01cead91f297d3c8` |
| `VMware-NSX-upgrade-bundle-3.2.4.3.0.24942842.mub` | 8.49 GB | `56d45a9e106f7ed04d977271867c07423e5ccb2319299daeb2a9b87630db8ae7` | `cf14c13d501966244388f991321120c7` |
| `VMware-CC-upgrade-bundle-3.2.4.3.0.24942842.mub` | 5.48 GB | `d84c6689304ec2763ac43f84ec2e56049989b1c39f14a11e1f6780df2aee80bc` | `c0f3814b7f62ca81f4d7cad8b081e634` |
| `VMware-NSX-edge-3.2.4.3.0.24942852.nub` | 32.88 MB | `3ca980a0aa653b6a463b967fba5cd1a770a1f3c16be80cda01f2d5c6a28fc103` | `c267b5bb97e05fbe3b1300bf2e5d75a8` |
| `nsx-lcp-3.2.4.3.0.24942844-esx70.zip` | 45.3 MB | `a6c05aab04c5629b331210a5fffaf08551f1636a667527a113d1eb8346f4503a` | `4c20efeb6927896ad10de48b701aa7bc` |
| `nsx-lcp-3.2.4.3.0.24942844-esx67.zip` | 31.55 MB | `b0bd4bfa2da159d25808bd7bd4a027b1e759c3160b866bff7a402bfbd845f7b6` | `eaaf9639cc947292423685117b6ec31b` |
| `nsx-lcp-3.2.4.3.0.24942844-esx65.zip` | 31.17 MB | `758b1c5d02af0a7f55934e6b1274c87d0a7c3605be79dd65016467ed1e91f0e6` | `0dfc36d1cc0f87a8aeba7a9d1c8177c5` |

Plus deprecated KVM qcow2 images and 14 bare-metal LCP bundles.
**Drivers & Tools:** Log Insight Content Pack 4.1.1.0 (206958), NSX Cloud Scripts 3.2.3 (206876 / 206877), NSX-T Automation SDK for Java 3.2.3 (206949), NSX Terraform Provider 3.2.9 (206952), NSX Container Plugin 3.2.1.8 (206975), NSX Ansible Modules 3.2.0 (206945).

---

## 8. VMware HCX

Releases: 4.11.5 (**543944**), 4.11.4 (540473), 4.11.3 (535690), 4.9.2 (524535), 4.8.3 (524692), 4.6.2 (202851), 4.4.3 (202850)

**4.11.5 (543944):**

| File | Size | Build | SHA256 | MD5 |
|---|---|---|---|---|
| `VMware-HCX-Cloud-4.11.5.0-25438872.ova` | 4 GB | 25438872 | `7fe7edefe807a0646d5834e2b997172d0e03e17a82b849db3e4b35d9879b5aee` | `d23eb211c404f0165c7969d20dc5db8b` |
| `VMware-HCX-Connector-4.11.5.0-25438871.ova` | 3.95 GB | 25438871 | `7b03de293e2a865580f5f02d9056b9ee5a5fd3dd59600ae6349fa4e8b95206d4` | `18b08c36b4a93a886b5379c140cb1386` |
| `VMware-HCX-Cloud-upgrade-bundle-4.11.5.0-25438872-signed.tar.gz` | 3.81 GB | 25438872 | `02d8759471eb436cd3e143ed52c284d6a24bde5f6fb863f18b65a110100d337d` | `73f399c17e318e06a2dcfb60371690bf` |
| `VMware-HCX-Connector-upgrade-bundle-4.11.5.0-25438871-signed.tar.gz` | 3.76 GB | 25438871 | `9d1f3bab5e9ab59ca81634ae66c9ebc38b21094e6ebebca1355bf7b0a5c1aca6` | `8d3ab104441e67a5dc9006e33a34e0bf` |

---

## 9. VMware Firewall (vDefend) — you hold this key

`subfamily=VMware Firewall` · display group `vDefend Firewall with Advanced Threat Prevention`
Single release row `5.X` (**529148**), itself a container of three sub-groups:

| Sub-group | Release id | groupId |
|---|---|---|
| vDefend Security Services Platform | FAM-SSP | 529149 |
| vDefend and Avi Conversion Tool | FAM-vACT | 544982 |
| License Hub for VMware vDefend and VMware Avi Load Balancers | FAM-LH | 545580 |

### 9.1 vDefend Security Services Platform 5.2.0 (level 543193)
Other releases in this sub-group: 5.1.1.1, 5.1.1, 5.0.0.1, 5.0.0

| File | Size | Build | SHA256 | MD5 |
|---|---|---|---|---|
| `Security-Services-Platform-for-vDefend-5.2.0.0.0.25669670.tar` | 19.75 GB | 25669670 | `bc47af49391bae897164c960e79d33702e83365ca5a8f5241d79942a9e9eaea5` | `154061152fb937be50d8b479ef0c147f` |
| `Security-Services-Platform-Installer-for-vDefend-and-Avi-5.2.0.0.0.25669671.ova` | 6.18 GB | 25669671 | `d8446576b08610484e8f2abf67ea38f12903245fb2eda30831054b070c814367` | `6e4b2399b2698f9c07279872ee83b25c` |
| `Security-Services-Platform-Installer-for-vDefend-and-Avi-upgrade-bundle-5.2.0.0.0.25669671.sub` | 6.54 GB | 25669671 | `489a73065495fe7e6c30ede2a82c5254d29c187a078de864a10864669353df0a` | `5089d63693ebc9b3cf54de1166b84786` |
| `NDR-Sensor-for-vDefend-5.2.0.0.0.25649484.ova` | 4.28 GB | 25649484 | `11b1d39bdacd6893a8aa2d73e760468ee60c480283fe46ab3552f9830f5f6571` | `0100c5a6cb4f9b3d2afbc48e171989e1` |
| `NDR-Sensor-for-vDefend-5.2.0.0.0.25649484.nub` | 1.54 GB | 25649484 | `05147c4cdb6f9b541c0421fb9cc6ec96c31470809147ead822ff67274774226c` | `af629fb66d34633d8b0daa9785dc69a9` |
| `onprem-sandbox-win11-for-vDefend-5.2.0.0.0-r25607725.ova` | 21.18 GB | r25607725 | `5fc8096bc0f42eeb54387a6968d0609a24139e45b8c3dfb40245b280ce12112f` | `6f6dcbfc458a097872c4852ccca0a341` |
| `onprem-sandbox-anonvpn-for-vDefend-5.2.0.0.0-r25548727.ova` | 898.18 MB | r25548727 | `38099a273cbebc6293fcd1f671105ab5cf47e4a8441377b3cd508ab3bd935064` | `a9201c5d896bec40fd8164be40ce118c` |

**Additional-Downloads (level 546429):** `Malware-Prevention-SVM-for-vDefend-5.2.0.0.0.25669670.tar`, 1.76 GB, SHA256 `888afda543718c6354ac18bb123c6f86a5e1c7fd8e5e2ba6e9009211ed4499e9`, MD5 `48dd493fe58704877e213e6beee96cf2`

**Drivers & Tools (level 546485):**

| File | Size | SHA256 | MD5 |
|---|---|---|---|
| `vDefend-GuestAgent-Bundle-8.5.2-25626756.tar.gz` | 5.32 MB | `1e8e11665d2a884ec72ede5bfa22335d2870e0b7304fea694a8f70eab35221f4` | `0d544f6823da1a6e7e1eae6a0cf96b23` |
| `vDefend_Threat_bundle_download.tar.gz` | 5.42 KB | `9108f4a054d01e773bd72429f68c514d574b6b6aa4e433d34f313b62f6a83374` | `04f3477fd7061953233fe9363c25faf3` |
| `VMWARE-PACKAGING-NSX-GI-GPG-RSA-KEY.pub` | 1.65 KB | `8f4cb443e17f533a78c72f1f7f7d7e1b739622bb8c2d2ac8444ac3fcf85e8307` | `3cf7bd5f7750173d1e1c243baaae2a06` |

### 9.2 License Hub 2.0 (level 544142) — gates your vDefend + Avi keys on 9.1

| File | Size | Build | SHA256 | MD5 |
|---|---|---|---|---|
| `License-Hub-2.0.0.0.0.25630952.ova` | 11.04 GB | 25630952 | `b5f1c1ba793c89fad725a4a6a3fdd24cf6c7ac73a5179f15724cb9ffe4b8052d` | `60b8bfd0bf31e30757ca38324c5f7d75` |

### 9.3 vDefend and Avi Conversion Tool 3.0.0 (544982)

| File | Size | SHA256 | MD5 |
|---|---|---|---|
| `avimigrationtools.ova` | 2.51 GB | `90b77581beef58fd842bd23bc338450c133bd26e17dd68e158dec8d0af5b0e32` | `8b1c2bae77287692f3b1553a17dfe56a` |

---

## 10. VMware Avi Load Balancer — you hold this key

Single display group. Releases (newest first): **32.1.2 (545334)**, 32.1.1 (540282),
**31.2.3 (546119)**, 31.2.2 (539110), 31.2.1 (529531), 31.1.2 (533549), 31.1.1 (525523),
30.2.7 (543585), 30.2.6 (537667), 30.2.5 (535030), 30.2.4 (532264), 30.2.3 (529604), 30.2.2 (521883),
30.2.1 (520352), 30.1.2 (112421), 30.1.1 (112419), 22.1.7 (522944), 22.1.6 (112460), 22.1.5 (112420),
22.1.4 (112418), plus older 22.1.x / 21.1.x / 20.1.x trains.

**No persona switch is needed** — Avi is a first-class family under the VCF persona.

### 10.1 Avi 32.1.2 (545334) — build 9077

| File | Size | SHA256 | MD5 |
|---|---|---|---|
| `controller-32.1.2-9077.ova` | 3.83 GB | `72031cc76f116a59e819592a3257d2ca5d3b5b69e86981a58e86b359a6c96e4c` | `0d06834841af5a6fac5cff8f6d2cc66d` |
| `controller-32.1.2-9077.pkg` | 3.58 GB | `2965c7940fa16bef6f6d387ffc905474073b8d7ea7dcf7f3e7f03c039886439a` | `e55a348dd12dc0f9165ac204a632f31d` |
| `controller-32.1.2-9077.qcow2` | 3.78 GB | `d53e48f9211dbe1971a884e7b0e8600a1166eb62e5b7ae340dea59aa4a8a2562` | `c028755c0ee7e6fd2e1e48d256dcbed9` |
| `controller-32.1.2-9077.raw.gz` | 3.54 GB | `0d203733c60659bcf57ce3bec8b3fa035eff64d2e53fd54c97afc192e3c49512` | `14aaed463e17c8c141201647e49b062d` |
| `controller-32.1.2-9077.vhd` | 11 GB | `7877fac5c4743932a66d67180d5f8f0dde578397833a6bb4fd55a35292d60ec3` | `bf04d38b50db5a0a3e911b1ca100f6e2` |
| `controller_docker-32.1.2-9077.tgz` | 4.47 GB | `09eb0d1bd0a47e97f109e8ae150943c6a3a2c91f5fb0af8ed7474339005409ba` | `d26cc30216277b8257d5a7ce2a244ac3` |
| `docker_install-32.1.2-9077.tar.gz` | 5.58 GB | `d0f88186a0344094dddec97fa98e50d39f8b0a7db04208fd0791a2b0d4387e91` | `f192170b6357247f6b2c8be110d78e72` |
| `gcp_controller-32.1.2-9077.tar.gz` | 3.54 GB | `3ee34906d57562eeae27368e6a4d505db58c4166897c49198e44428c78b8bb1a` | `65f212a473faf383a6883b59c87e6f17` |
| `se_docker-32.1.2-9077.tgz` | 1.14 GB | `26b7f3d2d979faea1963eaa5269f9b1326551a87ff903bdfcc67e41a127403c3` | `f31bc2fef81be493cf53412b6b1825d3` |
| `avi_shell-32.1.2-9077.tar.gz` | 2 MB | `e518cfe45f0481f4afb24decb8d69167e3a34a78760108f0eff61699b09813fc` | `33e545b57f8cbd0aed39a2e1c4806068` |
| `Default_password.txt` | 15 B | `dbf923acc107ca3f0180642543e5040aff6fc1336bad285dfd7a3d34fcebd889` | `bdf26ca65fd9e1fe5e45f383e3ffa68c` |

### 10.2 Avi 31.2.3 (546119) — build 9158

| File | Size | SHA256 | MD5 |
|---|---|---|---|
| `controller-31.2.3-9158.ova` | 4.65 GB | `e50d1c6782a84c760c3e6935b3a9ac4e8eb628d44ae53af9bf5b82250b585344` | `f8cc7ad9eb4e819836400af5c4563ff7` |
| `controller-31.2.3-9158.pkg` | 4.36 GB | `8f3318133bdffae8653d80b16522804a3faca47291d0feb234698e23b735825e` | `94b84a4dfb777ccf2fb9afac798dbb8b` |
| `controller-31.2.3-9158.qcow2` | 4.62 GB | `43d6ff2486eb4f09bf99afe33549ddfc1fe0a3255822d40a29ecde908ead80b0` | `d375cb571fa025d45f05e02e53496f70` |
| `controller-31.2.3-9158.raw.gz` | 4.31 GB | `362b1654f93f8c55a8462ce8f55190e47cc77529649e0490dfc084713e9f0ed7` | `3486562c1cb201b6b467dec07e0ca6f2` |
| `controller-31.2.3-9158.vhd` | 11 GB | `3c98d7dc986031a4a14b4468c6d7b96e9963f672540bb414b9195365ed1b0f14` | `d9d15c27cb8562205a16c486625d44dd` |
| `controller_docker-31.2.3-9158.tgz` | 5.36 GB | `aaaf7600329c7002a1407a2d97cfbeb6698cd649c6db97c146c5392f2a169306` | `50f551e8d61051cb84aecbc770cecdbd` |
| `docker_install-31.2.3-9158.tar.gz` | 6.6 GB | `c11a27b036f54207238e5f955fbd88310ccf5e97b07c233ae2565eeff29c3155` | `b7af5c53f83a8baec70cfdd7cb8abfe5` |
| `gcp_controller-31.2.3-9158.tar.gz` | 4.31 GB | `2081a7ef53dabc3f9e2d143fe9f589206540b0def24e61288db1d7d5b12e2ee2` | `8e415840e6100b54f93859e252f87340` |
| `se_docker-31.2.3-9158.tgz` | 1.26 GB | `5f6bfd5fe285afa617691666e235b0fe245415f5b834d1584926f4e6f2d13316` | `18bf90805b4e3e6ba708c54f3311c810` |

### 10.3 Avi WAF Core Rule Sets ("Drivers & Tools")

CRS-2026-2 / 20260710 (**545646**), CRS-2026-1 (543423), CRS-2025-2 (538676), CRS-2025-1 (529686),
CRS-2024-1 (522973), CRS-2023-4 (112430), CRS-2023-3 (112431), CRS-2023-2 (112429), CRS-2023-1 (112428),
CRS-2022-2 (112427), CRS-2022-1 (112426), CRS-2021-4 (112425), CRS-2021-3 (112424), CRS-2021-2 (112423),
CRS-2021-1 (112422).

Newest: `CRS-2026-2.json`, 389.23 KB, SHA256 `6512e7b341533e33e099ee5f1cb0461a5a6acc8b3d277e6ad97ac14d6c0d93a1`, MD5 `36b448dfd87c3e8bd30845d9507d95fe`

---

## 11. vSphere Supervisor Services

13 display groups, all download-enabled. Artifacts are small YAML service definitions plus a few CLIs.

| Service | Releases (servicePk) |
|---|---|
| vSphere Kubernetes Service | 3.7.1+v1.36 (**545584**), 3.7.0+v1.36 (544971), 3.6.3+v1.35 (544310), 3.6.2 (542259), 3.6.1 (542005), 3.6.0 (540237), 3.5.0+v1.34 (533366), 3.4.2+v1.33 (539588), 3.4.1 (535325), 3.4.0 (532624), 3.3.3 (532625), 3.3.2 (532611), 3.3.1 (532613), 3.3.0 (532646), 3.2.0 (532627), 3.1.1 (532480), 3.1.0 (531029) |
| Harbor | 2.14.3 (**542081**), 2.14.2 (540295), 2.13.1 (531888), 2.12.4 (531231), 2.11.2 (531095), 2.9.1 (531094) |
| Contour | 1.33.1 (**540719**), 1.32.0 (534236), 1.31.1 (534235), 1.30.3 (531887), 1.29.3 (531099), 1.28.2 (531098) |
| External DNS | 0.21.0 (**544541**), 0.18.0 (540717), 0.14.2 (531102) |
| Local Consumption Interface | 9.1.1 (**544539**), 9.1.0.0 (541120), 9.0.2 (537486), 9.0.1 (533784), 9.0.0 (531312), 1.0.2 (531036) |
| Velero vSphere Operator | 1.8.1 (**533135**), 1.8.0 (532672) |
| Supervisor Management Proxy | 0.4.1 (**541121**), 0.4.0 (533607), 0.3.0 (531242) |
| NSX Management Proxy | 0.2.2 (**531106**), 0.2.1 (531105), 0.1.1 (531103) |
| Secret Store | 9.0.1.0 (**534936**), 9.0.0.0 (531108) |
| ArgoCD Service | 1.1.0 (**538499**), 1.0.1 (533789), 1.0.0 (531314) |
| MinIO | 2.0.10 (**531037**) |
| Metrics Aggregator | 0.1.0 (**541370**) |
| ca-clusterissuer | 0.0.2 (**531093**), 0.0.1 (531092) |

Notable non-YAML artifacts: `velero-vsphere-1.8.1-linux-amd64.tar.gz` (34.19 MB, SHA256
`f2ce1fc6af7ecfc3eb9abcc750254c829301e2ebde2974845b455bc03c8c52a6`) and the ArgoCD CLI trio
(`argocd-cli-{linux,darwin,windows}-amd64-v3.0.19-vcf.gz`, 55–67 MB each). Full per-file hashes for all
13 services were captured and are available on request — omitted here for length.

---

## 12. Aria / VCF Operations 8.18 stack

### 12.1 Product downloads

| Family | Display group | Current release (servicePk) |
|---|---|---|
| `VMware Aria Automation` | VMware Aria Automation | 8.18.1 (**523683**), 8.18.0 (521124) |
| `VMware Aria Automation` | VMware Aria Automation Orchestrator | 8.18.1 (**523703**), 8.18.0 (521125) |
| `VMware Aria Operations` | VMware Aria Operations | 8.18.7 (**543353**), .6 (539057), .5 (535446), .4 (533025), .3 (527515), .2 (525464), .1 (523019), .0 (520464), 8.17.2 (520768), 8.17.1 (208588), 8.16.1 (208587), 8.16.0 (202993) |
| `VMware Aria Operations for Logs` | same | 8.18.7 (**543355**), .6 (539642), .5 (535466), .4 (533027), .3 (527517), .1 (525726), .0 (520484), 8.16.1 (520770), 8.16.0 (208590) |
| `VMware Aria Operations for Networks` | same | 6.14.3 (**543428**), 6.14.2 (539953), 6.14.1 (534205), 6.14.0 (522384), 6.13.0 (520361) |
| `VMware Identity Manager` | same | 3.3.7 (**203475**) |

**Aria Automation Orchestrator 8.18.1 (523703):**

| File | Size | SHA256 | MD5 |
|---|---|---|---|
| `O11N_VA-8.18.1.36791-24281602_OVF10.ova` | 3.82 GB | `1abadd6ee89a0f03f9973352e28ee4ebf32fe0c1c86e50432fb7c7162239271c` | `05bffabbe3fb44b20cb78d503b0d6c8a` |
| `O11N_VA-8.18.1.36791-24281602-updaterepo.iso` | 3.47 GB | `99298a1c9b912f20eccae3f5847b7994a932b8f9dfded07d38f08a1e78ea1143` | `560284134879e9c4a71a5b3abcc25d0f` |

Per-file listings for Aria Automation 8.18.1, Aria Operations 8.18.7, Logs 8.18.7, AON 6.14.3 and
vIDM 3.3.7 are in the companion `MEDIA-INVENTORY-2026-08-27.md`.

### 12.2 Patch / solution index (`?subfamily=<FAMILY>&tab=Solutions`)

All records below returned **Distribution Code AVAILABLE** with enabled download controls. Patch access
is *not* restricted on this entitlement.

**Aria Automation → 8.18.1**

| Patch | FIX id | Published | patchId |
|---|---|---|---|
| Update 5 | AriaLCM-AriaAuto-8.18.1-U5 | 2026-05-27 | **16081** |
| Update 4 | AriaLCM-AriaAuto-8.18.1-U4 | 2026-02-24 | 16051 |
| Upgrade Binaries 8.11.2 / 8.16.0 / 8.16.2 | Upgrade-Binaries-AriaAutomation | 2025-11-11 | 16017 |
| Update 3 | AriaLCM-AriaAuto-8.18.1-U3 | 2025-07-29 | 15967 |
| Update 2 | AriaLCM-AriaAuto-8.18.1-U2 | 2025-04-30 | 5850 |
| Patch 1 | AriaLCM-AriaAuto-8.18.1-PATCH1 | 2025-01-06 | 5747 |

Key files — **16081 (CU5, current):** `vrlcm-vra-8.18.1-8.18.1.37370.patch` 9.56 GB, SHA256
`eb9b2dca754e111efae69a0aad017d5316217c154cc507b5cd9011f70f56e399`, MD5 `4e4e731329d48e8784292dca871171fc`
· `O11N_VA-8.18.1.37367-25423020-updaterepo.iso` 3.59 GB, SHA256
`11d3f5a161b78d415a24c0adf6143218b9500e9289131d496ec997dc5d2421ea`, MD5 `99c02f830c23e611089ee2106bec34a4`

**Aria Automation Orchestrator → 8.18.1**

| Patch | FIX id | Published | patchId |
|---|---|---|---|
| Update 6 | Aria-Orchestrator-8.18.1-U6 | 2026-05-27 | **16080** |
| Update 5 | Aria-Orchestrator-8.18.1U5 | 2026-02-24 | 16050 |
| Upgrade Binaries 8.8.2→8.18.1 | Upgrade-Aria-Orchestrator | 2025-10-15 | 16004 |
| Update 4 | Aria-Orchestrator-8.18.1U4 | 2025-09-29 | 15991 |
| Update 3 | Aria-Orchestrator-8.18.1U3 | 2025-07-29 | 15968 |

**16080:** `O11N_VA-8.18.1.37367-25423020_OVF10.ova` 3.93 GB, SHA256
`ecca269aaee49b49d94d9b048445049210967e77178f73c1727e04104475b91b`, MD5 `791a40b8ef6b55158df2239726fef2b4`

**Aria Suite Lifecycle:** `vrlcm-8.18.0-PATCH9.patch`, patchId **16116**, 1.8 GB, build 25621957,
SHA256 `0a66e891021bb3cecefdd184ec9ecae3b51929f98180e11afad8a3150bb1ec1e`, MD5 `c01f96c600fa41ce1fc0b40fcf7a25c8`

**Aria Operations → 8.18.0** (19 records; hotfixes are published in ASL/product pairs)

| Patch | Published | patchId (ASL / product) |
|---|---|---|
| HF9 | 2025-11-28 | **16027** / **16026** |
| HF8 | 2025-10-21 | 16007 / 16006 |
| HF7 | 2025-09-01 | 15983 / 15982 |
| HF6 | 2025-05-21 | 5859 / 5858 |
| HF5 | 2025-04-01 | 5818 / 5817 |
| HF4 | 2025-02-20 | 5779 / 5777 |
| HF2 | 2024-08-22 | 5512 / 5511 |
| HF1 | 2024-08-08 | 5506 / 5504 |
| Upgrade Binaries 8.12.0 / 8.14.1 | 2025-10-01 | 15997 |
| Telegraf Agent Cleanup Script | 2025-11-17 | 16018 |

**16027 (HF9, ASL side)** carries six ~5.1 GB patches, one per base version 8.18.0 → 8.18.5.
**16026 (HF9, product side):** `vRealize_Operations_Manager_With_CP-8.14.x-to-8.18.5.25072631.pak` 4.96 GB,
SHA256 `db1880ba25079a6a5f92be2b5951ff5cdaf0f4b3a1492214d498e20d78b7961c`, MD5 `c70fe9dba2683cea8d3c8e5315d9310d`

**Aria Operations for Logs → 8.18.0:** `vrlcm-vrli-8.18.0-HF1` patchId **5505** (1010.74 MB, SHA256
`fe9dacdf0e3d1b4283861b40fbbf39340bad978a09626faea8ec8b24bb2dea88`) · product-side HF1 patchId **5502**
· Upgrade Binaries 8.1.1→8.14.1 patchId 5464

**Aria Operations for Networks → 6.14.0:** P8 patchId **15949** (`vrlcm-vrni-6.14.0-6.14.0.P8.1749832225.patch`,
996.35 MB, SHA256 `b1cb3d45b2d1f88007bd92b29225e0ba81ceba680cf7beb6835a087e52309695`) · P6 patchId 5868 ·
P5 5843 · P4 5811 / 5812

⚠️ **The Solutions list for the *current* release of each family is empty.** Aria Ops 8.18.7,
Logs 8.18.7 and AON 6.14.3 all return zero records. Patches are filed under the **base** release
(8.18.0 / 6.14.0). Automation must query the base release, not the deployed one.

---

## 13. Dead ends — do not waste automation cycles here

| Target | Result |
|---|---|
| `VMware Aria Suite Lifecycle` as a `subfamily` | No such family — returns "No data found" |
| `VCF Operations/Automation (formerly VMware Aria Suite)` | Exists in All Products; Products and Solutions tabs both empty |
| `VMware vRealize Network Insight` Products tab | Empty. Solutions tab has 6.9.0 (empty) / 6.8.0 (one LCM patch record) / 6.6.0 |
| `VMware Aria Suite` (2019) | Manifest of View-Group pointers only — see §3 |
| Portal global search (`/web/ecx/search`) | An AI chat agent, not a file index. Useless for enumeration |
| Clicking "View Group" anywhere | Broken portal-wide — see §0.2 |

---

## 14. License entitlements

Broadcom Certification License Portal — `https://support.broadcom.com/group/ecx/alpine-certificate`
All three tiles are **already approved**; nothing is pending, so there is no request/approval latency to
schedule around.

| Tile SKU | Qty | Expires | Media download | License key |
|---|---|---|---|---|
| `VCF-CLD-FND` | 128 | 2027-08-14 | ✅ | ✅ |
| `ANS-VDEFEND` | 128 | 2027-08-14 | — | ✅ |
| `ANS-VMW-ALB` | 12 | 2027-08-14 | ✅ | ✅ |

The uniform **2027-08-14** expiry is the outer bound on the whole build — tighter than any per-product
eval clock. vDefend having a key icon but no media icon confirms it ships no installable media of its
own; it is a key applied to NSX Manager (4.2.x/5.2.x) or via License Hub 2.0 (9.1).
