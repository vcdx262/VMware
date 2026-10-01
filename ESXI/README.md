# ESXI

PowerCLI for deploying and validating ESXi hosts — a working toolkit built across
real vSphere engagements. Some files are fully parameterized tools; others are
operational snippets that expect a host collection to be populated and a vCenter
session open (`Connect-VIServer`) first.

| Script | Purpose | Shape |
|---|---|---|
| `Deploy-NestedESXI.ps1` | Bulk-deploy nested ESXi from an OVF via a per-VM CSV | Parameterized tool |
| `DeployESXIAppliances.ps1` | Build a lab datacenter/cluster and deploy + join nested hosts | Script (env vars for creds) |
| `Verify-Hosts.ps1` | Wide host config baseline (syslog/NTP/SNMP/vmk/VDS/datastore/HBA/LUN/DNS/stacks/auth) → CSV | Parameterized tool |
| `Verify-NICs.ps1` | Physical vmnic link state (speed/duplex) per host | Snippet (`$testhost`) |
| `Verify-NTP.ps1` | ntpd service policy/running state per host | Snippet (`$VMHosts`) |
| `HBA-Verification.ps1` | Emulex HBA presence/status + datastore accessibility | Snippet (`$VMHosts`) |
| `Get-HBAs.ps1` | HBA inventory across all connected vCenters → CSV | Snippet (all vCenters) |
| `Get-ScsiLun.ps1` | SCSI LUN inventory incl. SSD/vSAN state → CSV | Snippet (all vCenters) |
| `Create-Vmotion.ps1` | Add vMotion VMkernel adapters from a collection | Snippet (`$vmotion`) |

**Prerequisites:** VMware PowerCLI; a vCenter connection (`Connect-VIServer`). Edit the
CSV / export paths near the top of each script for your environment.
