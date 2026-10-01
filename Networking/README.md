# Networking

vSphere Distributed Switch (VDS) and portgroup automation, plus reporting on virtual
networking configuration — all CSV-driven where it creates objects.

| Script | Purpose |
|---|---|
| `Create-VDS.ps1` | Create Distributed Switches from `VDS-Config.csv` (version, MTU, uplinks, discovery, contact) |
| `Create-PortGroups.ps1` | Create distributed portgroups and set active/standby/unused uplink teaming from `PortGroups.csv` |
| `Get-DvPorts.ps1` | Report DVS portgroup security/teaming/LACP/IPFIX settings → CSV |
| `Get-StdPorts.ps1` | Report standard vSwitch portgroups (VLAN, teaming, security) across vCenters → CSV |

**Prerequisites:** VMware PowerCLI; `Connect-VIServer`. Point the `Import-Csv` paths at
your input files before running the creation scripts.
