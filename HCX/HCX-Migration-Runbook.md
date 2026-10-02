# HCX Migration Runbook — site pairing to cutover

**Why this exists:** the operator path for migrating workloads with VMware HCX — from site
pairing and service-mesh build to running and validating migrations — with the status
script in this folder for tracking.

> Lab values throughout. HCX spans a **source** (on-prem) and **destination** (target
> SDDC / cloud). Read-only status via [`Get-HCXMigrationStatus.ps1`](Get-HCXMigrationStatus.ps1).

## 0. Ground truth (fill in)

| | |
|---|---|
| Source HCX | `hcx-src.lab.local` (Connector) |
| Destination HCX | `hcx-dst.lab.local` (Cloud Manager) |
| Migration types | Bulk, vMotion, RAV (Replication-Assisted vMotion), Cold |
| Network extension | stretched segments for zero IP-change migration |

## 1. Pair + mesh

1. Register HCX at both sites; create the **site pairing**.
2. Build **network/compute profiles** at each site.
3. Deploy the **service mesh** (IX, NE, WAN-opt appliances); confirm tunnels **Up**.

## 2. Extend networks (optional, for IP preservation)

Stretch the source L2 segments to the destination so VMs keep their IPs through migration.

## 3. Plan + run migrations

1. Choose the type per workload: **Bulk** (scheduled, resilient, many VMs), **vMotion**
   (live, one at a time), **RAV** (live + scheduled cutover, best of both), **Cold**.
2. Create the migration group, set the cutover window, start.
3. Track:

```powershell
.\Get-HCXMigrationStatus.ps1 -HcxServer hcx-src.lab.local -Path .\HCX-Migrations.csv
```

## 4. Cutover + validate

- Trigger cutover (or let scheduled RAV/Bulk cut over in-window).
- Confirm guest boots, VMware Tools, IP (preserved if network-extended), app health.
- Un-stretch networks once the source side is retired.

## 5. Common gotchas

- Underlay MTU must carry the HCX overlay (1600+); TEP/uplink MTU mismatches stall tunnels.
- RAV needs sufficient replication bandwidth; Bulk is more forgiving on lossy links.
- Network extension is the lever for migrating in small groups without re-IP.
