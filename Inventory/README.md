# Inventory

Read-only reporting across a vSphere environment (all connected vCenters, or one via
`-Server`). Standard `$results` / `[pscustomobject]` / `Export-Csv` pattern.

| Script | Purpose |
|---|---|
| `Get-vSphereInventory.ps1` | Four-part inventory → one CSV each: Clusters, Hosts, VMs, Datastores |
| `Get-ClusterCapacity.ps1` | Per-cluster CPU/mem allocation vs. physical, vCPU:pCPU overcommit, N+1 headroom, "avg VM" headroom estimate |
| `Get-VMSnapshotAging.ps1` | Snapshot age/size with stale flag + a VM-hygiene report (VMware Tools, connected media) |

**Prerequisites:** VMware PowerCLI and an active `Connect-VIServer` session.
