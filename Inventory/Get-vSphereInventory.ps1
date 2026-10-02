<#
.SYNOPSIS
    Inventories a vSphere environment (clusters, hosts, VMs, datastores) to CSV.
.DESCRIPTION
    Across every connected vCenter (or a specified one), collects a four-part inventory
    and writes one CSV per object class to an output folder:
      - Clusters   : HA/DRS state, host and VM counts, total/used CPU and memory
      - Hosts      : version/build, model, CPU/memory, connection/power state, uptime
      - VMs        : power state, vCPU, memory, provisioned/used disk, VMtools, guest OS
      - Datastores : type, capacity, free, used %
    Follows the standard $results / [pscustomobject] / Export-Csv reporting pattern.
.PARAMETER Server
    Optional vCenter to query. Defaults to all connected servers ($global:DefaultVIServers).
.PARAMETER OutputFolder
    Folder for the CSV output. Created if missing. Default .\vSphere-Inventory
.EXAMPLE
    Connect-VIServer vc01.lab.local
    .\Get-vSphereInventory.ps1 -OutputFolder .\inv
.NOTES
    Author : Steven Slocum (VCDX #262)
    Notes  : Read-only. Requires VMware PowerCLI and an active Connect-VIServer session.
#>

[CmdletBinding()]
param(

    [parameter(Mandatory = $false)]
    [string]$Server,

    [parameter(Mandatory = $false)]
    [string]$OutputFolder = '.\vSphere-Inventory'

)

if (-not (Test-Path -LiteralPath $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
}

$svrArg = @{}
if ($Server) { $svrArg['Server'] = $Server }

#--- Clusters ---
$clusterResults = @()
foreach ($cl in (Get-Cluster @svrArg)) {
    $obj = $null
    $chosts = $cl | Get-VMHost
    $obj = [pscustomobject]@{
        Cluster       = $cl.Name
        HAEnabled     = $cl.HAEnabled
        DrsEnabled    = $cl.DrsEnabled
        DrsAutomation = $cl.DrsAutomationLevel
        Hosts         = ($chosts | Measure-Object).Count
        VMs           = ($cl | Get-VM | Measure-Object).Count
        TotalCpuGhz   = [math]::Round((($chosts | Measure-Object CpuTotalMhz -Sum).Sum)/1000, 1)
        TotalMemGB    = [math]::Round((($chosts | Measure-Object MemoryTotalGB -Sum).Sum), 0)
    }
    $clusterResults += $obj
}
$clusterResults | Export-Csv (Join-Path $OutputFolder 'Clusters.csv') -NoTypeInformation

#--- Hosts ---
$hostResults = @()
foreach ($h in (Get-VMHost @svrArg)) {
    $obj = $null
    $obj = [pscustomobject]@{
        VMHost        = $h.Name
        Cluster       = $h.Parent.Name
        Version       = $h.Version
        Build         = $h.Build
        Model         = $h.Model
        CpuCores      = $h.NumCpu
        MemoryGB      = [math]::Round($h.MemoryTotalGB, 0)
        ConnState     = $h.ConnectionState
        PowerState    = $h.PowerState
    }
    $hostResults += $obj
}
$hostResults | Export-Csv (Join-Path $OutputFolder 'Hosts.csv') -NoTypeInformation

#--- VMs ---
$vmResults = @()
foreach ($vm in (Get-VM @svrArg)) {
    $obj = $null
    $obj = [pscustomobject]@{
        VM             = $vm.Name
        PowerState     = $vm.PowerState
        vCPU           = $vm.NumCpu
        MemoryGB       = $vm.MemoryGB
        ProvisionedGB  = [math]::Round($vm.ProvisionedSpaceGB, 1)
        UsedGB         = [math]::Round($vm.UsedSpaceGB, 1)
        GuestOS        = $vm.Guest.OSFullName
        VMToolsStatus  = $vm.Guest.ExtensionData.ToolsStatus
        VMHost         = $vm.VMHost.Name
        HardwareVer    = $vm.HardwareVersion
    }
    $vmResults += $obj
}
$vmResults | Export-Csv (Join-Path $OutputFolder 'VMs.csv') -NoTypeInformation

#--- Datastores ---
$dsResults = @()
foreach ($ds in (Get-Datastore @svrArg)) {
    $obj = $null
    $usedPct = if ($ds.CapacityGB) { [math]::Round((($ds.CapacityGB - $ds.FreeSpaceGB) / $ds.CapacityGB) * 100, 0) } else { $null }
    $obj = [pscustomobject]@{
        Datastore   = $ds.Name
        Type        = $ds.Type
        CapacityGB  = [math]::Round($ds.CapacityGB, 0)
        FreeGB      = [math]::Round($ds.FreeSpaceGB, 0)
        UsedPct     = $usedPct
    }
    $dsResults += $obj
}
$dsResults | Export-Csv (Join-Path $OutputFolder 'Datastores.csv') -NoTypeInformation

Write-Verbose "vSphere inventory written to $OutputFolder"
[pscustomobject]@{
    Clusters   = $clusterResults.Count
    Hosts      = $hostResults.Count
    VMs        = $vmResults.Count
    Datastores = $dsResults.Count
    OutputFolder = (Resolve-Path $OutputFolder).Path
}
