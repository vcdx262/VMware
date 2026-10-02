# vSphere Cluster Deployment Guide — hosts to a production-ready cluster

**Why this exists:** the repeatable path from freshly-imaged ESXi hosts to a validated
vSphere cluster (HA + DRS + vSAN-ready + distributed networking), using the scripts in
this repo. Each phase has a verification; record them in the companion test plan.

> Run PowerCLI from a workstation with network reach to vCenter/ESXi. Preview changes with
> `-WhatIf` where supported. Lab values shown (`lab.local`, RFC1918) — substitute yours.

## 0. Ground truth (fill in)

| | |
|---|---|
| vCenter | `vc01.lab.local` |
| Cluster | `Cluster-A` (HA, DRS fully automated) |
| Hosts | `esx01–esx04.lab.local` |
| Distributed switch | `vds-prod` (MTU 9000) |
| Storage | vSAN or shared VMFS/NFS |

## 1. PowerCLI baseline

```powershell
.\ESXI\Install-PowerCLIBaseline.ps1 -CertificateAction Warn
Connect-VIServer vc01.lab.local
```

## 2. Create the cluster + add hosts

```powershell
New-Cluster -Name Cluster-A -Location (Get-Datacenter) -HAEnabled -DrsEnabled -DrsAutomationLevel FullyAutomated
Get-Content .\hosts.txt | ForEach-Object { Add-VMHost $_ -Location Cluster-A -User root -Password $env:ESXI_PASSWORD -Force }
```

## 3. Distributed networking

```powershell
.\Networking\Create-VDS.ps1            # from VDS-Config.csv
.\Networking\Create-PortGroups.ps1     # from PortGroups.csv
.\ESXI\Create-Vmotion.ps1              # vMotion VMkernels from a collection
```

## 4. Verify host configuration baseline

```powershell
.\ESXI\Verify-Hosts.ps1 -InputFile .\hosts.txt -OutputFile .\baseline.csv
.\ESXI\Verify-NTP.ps1
.\ESXI\Get-HBAs.ps1
```

## 5. Capacity + inventory snapshot

```powershell
.\Inventory\Get-vSphereInventory.ps1 -OutputFolder .\inv
.\Inventory\Get-ClusterCapacity.ps1
```

## 6. Validate

Work through **[vSphere-Host-Buildout-Test-Plan.xlsx](../ESXI/vSphere-Host-Buildout-Test-Plan.xlsx)**
recording Expected vs. Actual. For vSAN, continue with
**[vSAN-Health-Validation-Test-Plan.xlsx](../vSAN/vSAN-Health-Validation-Test-Plan.xlsx)**.
