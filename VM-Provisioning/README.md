# VM-Provisioning

Bulk VM deployment from vSphere templates using cloned OS Customization Specs, driven
by a per-VM CSV. One VM per CSV row; IPv4/IPv6 static or DHCP per VM.

| Script | Purpose |
|---|---|
| `Deploy-WindowsVM.ps1` | Deploy Windows VMs; CSV uses four DNS fields (IPv4Dns1/2, IPv6Dns1/2) |
| `Deploy-LinuxVM.ps1` | Deploy Linux VMs; CSV uses three DNS fields (Dns1/2/3) |

**Logic:** import CSV → connect to vCenter → clone a customization spec into a temp spec
→ apply per-VM network settings → deploy from the named template onto the chosen
cluster/host/datastore → repeat per row → clean up.

**Prerequisites (validated against):** vSphere 7.0u2, VMware PowerCLI 12.2.0, PowerShell 7.1+.
Requires an existing vCenter **template** and **OS customization spec** to clone.

> Consolidated from the former standalone `Deploy-VM` repository.
