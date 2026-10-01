# Hardware

Bare-metal inventory/audit for the physical tier beneath vSphere.

| Script | Purpose |
|---|---|
| `Audit-idrac.ps1` | Query Dell iDRAC via the Redfish REST API (self-signed TLS tolerated) for hardware inventory across a list of iDRACs |
| `Inventory-UCSssd.ps1` | Enumerate Cisco UCS service profiles and correlate SSD health stats (UCS PowerTool) |

**Prerequisites:** `Audit-idrac.ps1` — network reach to iDRAC Redfish; credentials passed
as parameters (password is a `SecureString`). `Inventory-UCSssd.ps1` — Cisco UCS PowerTool
module; prompts for credentials.
