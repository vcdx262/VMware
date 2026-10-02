<#
.SYNOPSIS
    Reports vSphere cluster capacity and consolidation headroom.
.DESCRIPTION
    For each cluster (across connected vCenters or a specified one), reports physical vs.
    allocated CPU and memory, live usage, the resulting vCPU:pCPU overcommit ratio, an
    estimate of remaining "average VM" headroom, and N+1 failover headroom (capacity with
    one host removed). One row per cluster — a quick read on how much more each can take.
.PARAMETER Server
    Optional vCenter. Defaults to all connected ($global:DefaultVIServers).
.PARAMETER Path
    Output CSV path. Default .\vSphere-ClusterCapacity.csv
.PARAMETER AvgVmVcpu
    Assumed vCPU per "average VM" for headroom estimate. Default 2.
.PARAMETER AvgVmMemGB
    Assumed memory (GB) per "average VM" for headroom estimate. Default 8.
.EXAMPLE
    Connect-VIServer vc01.lab.local
    .\Get-ClusterCapacity.ps1
.NOTES
    Author : Steven Slocum (VCDX #262)
    Notes  : Read-only. Requires VMware PowerCLI + an active session. The headroom figure
             is a planning estimate from the Avg* assumptions, not a scheduler guarantee.
#>

[CmdletBinding()]
param(

    [parameter(Mandatory = $false)]
    [string]$Server,

    [parameter(Mandatory = $false)]
    [string]$Path = '.\vSphere-ClusterCapacity.csv',

    [parameter(Mandatory = $false)]
    [int]$AvgVmVcpu = 2,

    [parameter(Mandatory = $false)]
    [int]$AvgVmMemGB = 8

)

$svrArg = @{}
if ($Server) { $svrArg['Server'] = $Server }

$results = @()

foreach ($cl in (Get-Cluster @svrArg)) {

    $obj     = $null
    $chosts  = @($cl | Get-VMHost | Where-Object { $_.ConnectionState -eq 'Connected' })
    $vms     = @($cl | Get-VM)
    $onVms   = @($vms | Where-Object { $_.PowerState -eq 'PoweredOn' })

    $pCpu    = ($chosts | Measure-Object NumCpu -Sum).Sum
    $physMem = ($chosts | Measure-Object MemoryTotalGB -Sum).Sum
    $allocVcpu = ($onVms | Measure-Object NumCpu -Sum).Sum
    $allocMem  = ($onVms | Measure-Object MemoryGB -Sum).Sum

    #live usage
    $usedCpuGhz = [math]::Round((($chosts | Measure-Object CpuUsageMhz -Sum).Sum)/1000, 1)
    $usedMemGB  = [math]::Round((($chosts | Measure-Object MemoryUsageGB -Sum).Sum), 0)

    #N+1: largest host removed
    $perHostMem = if ($chosts.Count) { [math]::Round($physMem / $chosts.Count, 0) } else { 0 }
    $nPlus1MemGB = [math]::Round($physMem - $perHostMem, 0)

    $obj = [pscustomobject]@{
        Cluster          = $cl.Name
        Hosts            = $chosts.Count
        PhysicalVcpu     = $pCpu
        AllocatedVcpu    = $allocVcpu
        VcpuOvercommit   = if ($pCpu) { [math]::Round($allocVcpu / $pCpu, 2) } else { $null }
        UsedCpuGhz       = $usedCpuGhz
        PhysicalMemGB    = [math]::Round($physMem, 0)
        AllocatedMemGB   = [math]::Round($allocMem, 0)
        UsedMemGB        = $usedMemGB
        MemCommitPct     = if ($physMem) { [math]::Round(($allocMem / $physMem) * 100, 0) } else { $null }
        NPlus1MemGB      = $nPlus1MemGB
        EstAvgVMHeadroom = if ($AvgVmMemGB) { [math]::Floor(($physMem - $allocMem) / $AvgVmMemGB) } else { $null }
    }

    $results += $obj
}

$results | Export-Csv -Path $Path -NoTypeInformation
$results
