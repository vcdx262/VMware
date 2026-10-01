# Lab

Scripts and notes for standing up the Windows/AD foundation of a vSphere home lab
(the lab behind much of the rest of this repo). Lab-only; uses `lab.local` and RFC1918.

| File | Purpose |
|---|---|
| `Install-DNS-AD.ps1` | Install DNS + AD DS roles and promote a new forest (prompts for DSRM password) |
| `Configure-DNS.ps1` | Seed reverse zone, forwarder and lab A/PTR records (vCenter, ESXi, NSX, vRNI) |
| `DC-Build-Notes.txt` | Operator notes for the domain controller build |
| `Lab-Notes-WindowsImages.txt` | Notes on Windows image prep for the lab |
