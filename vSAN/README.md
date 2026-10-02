# vSAN

vSAN validation tooling.

| File | Purpose |
|---|---|
| `vSAN-Health-Validation-Test-Plan.xlsx` | Phase-by-phase vSAN enablement + health + resilience validation (9-column tracker) |

Capacity and datastore reporting for vSAN is covered by
[`../Inventory/Get-vSphereInventory.ps1`](../Inventory/Get-vSphereInventory.ps1) (Datastores.csv)
and [`../Inventory/Get-ClusterCapacity.ps1`](../Inventory/Get-ClusterCapacity.ps1).

> Script-based vSAN health automation (`Test-VsanClusterHealth`, storage-policy compliance)
> is on the roadmap.
