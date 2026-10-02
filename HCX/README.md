# HCX

VMware HCX workload-mobility tooling and a migration runbook.

| File | Purpose |
|---|---|
| `Get-HCXMigrationStatus.ps1` | Report migration status (type, state, progress, source/dest) via the HCX REST API; flags failed migrations |
| `HCX-Migration-Runbook.md` | Site pairing → service mesh → network extension → migrate → cutover runbook |

**Prerequisites:** PowerShell 7+ (self-signed HCX cert handling); HCX Connector/Manager reachable.

> Maps to real HCX-based DR and datacenter-exit migration experience (bulk/vMotion/RAV,
> network extension for IP-preserving moves).
