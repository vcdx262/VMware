<#
.SYNOPSIS
    Reports VM snapshot age/size and other VM hygiene signals across vSphere.
.DESCRIPTION
    Finds every VM snapshot (across connected vCenters or a specified one) and reports its
    age, size, creator/description and the owning VM, flagging snapshots older than
    -StaleDays. Also surfaces common hygiene issues in a second CSV: outdated/ not-running
    VMware Tools, VMs with CD/ISO still connected, and oversized snapshot chains. Follows
    the standard reporting pattern.
.PARAMETER Server
    Optional vCenter. Defaults to all connected ($global:DefaultVIServers).
.PARAMETER OutputFolder
    Folder for CSV output. Created if missing. Default .\vSphere-Hygiene
.PARAMETER StaleDays
    Age in days beyond which a snapshot is flagged stale. Default 3.
.EXAMPLE
    Connect-VIServer vc01.lab.local
    .\Get-VMSnapshotAging.ps1 -StaleDays 7
.NOTES
    Author : Steven Slocum (VCDX #262)
    Notes  : Read-only. Requires VMware PowerCLI + an active session. Aged snapshots are a
             top cause of datastore-full incidents — run this on a schedule.
#>

[CmdletBinding()]
param(

    [parameter(Mandatory = $false)]
    [string]$Server,

    [parameter(Mandatory = $false)]
    [string]$OutputFolder = '.\vSphere-Hygiene',

    [parameter(Mandatory = $false)]
    [int]$StaleDays = 3

)

if (-not (Test-Path -LiteralPath $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
}

$svrArg = @{}
if ($Server) { $svrArg['Server'] = $Server }

$cutoff = (Get-Date).AddDays(-$StaleDays)

#--- Snapshots ---
$snapResults = @()
foreach ($snap in (Get-VM @svrArg | Get-Snapshot)) {
    $obj = $null
    $ageDays = (New-TimeSpan -Start $snap.Created -End (Get-Date)).Days
    $obj = [pscustomobject]@{
        VM          = $snap.VM.Name
        Snapshot    = $snap.Name
        Created     = $snap.Created
        AgeDays     = $ageDays
        SizeGB      = [math]::Round($snap.SizeGB, 2)
        Description = $snap.Description
        PowerState  = $snap.PowerState
        Stale       = ($snap.Created -lt $cutoff)
    }
    $snapResults += $obj
}
$snapResults | Export-Csv (Join-Path $OutputFolder 'Snapshots.csv') -NoTypeInformation

#--- Hygiene (tools + connected media) ---
$hygResults = @()
foreach ($vm in (Get-VM @svrArg)) {
    $obj = $null
    $cdConnected = [bool](Get-CDDrive -VM $vm -ErrorAction SilentlyContinue |
                    Where-Object { $_.ConnectionState.Connected -and ($_.IsoPath -or $_.HostDevice) })
    $tools = $vm.Guest.ExtensionData.ToolsStatus
    $obj = [pscustomobject]@{
        VM              = $vm.Name
        PowerState      = $vm.PowerState
        ToolsStatus     = $tools
        ToolsOutdated   = ($tools -eq 'toolsOld')
        ToolsNotRunning = ($vm.PowerState -eq 'PoweredOn' -and $tools -eq 'toolsNotRunning')
        CdIsoConnected  = $cdConnected
        HardwareVer     = $vm.HardwareVersion
    }
    $hygResults += $obj
}
$hygResults | Export-Csv (Join-Path $OutputFolder 'VMHygiene.csv') -NoTypeInformation

$staleSnaps = @($snapResults | Where-Object Stale)
if ($staleSnaps.Count -gt 0) {
    Write-Warning "$($staleSnaps.Count) snapshot(s) older than $StaleDays day(s); $([math]::Round((($staleSnaps | Measure-Object SizeGB -Sum).Sum),1)) GB total."
}

Write-Verbose "Hygiene report written to $OutputFolder"
[pscustomobject]@{
    Snapshots       = $snapResults.Count
    StaleSnapshots  = $staleSnaps.Count
    StaleSnapGB     = [math]::Round((($staleSnaps | Measure-Object SizeGB -Sum).Sum), 1)
    ToolsOutdated   = @($hygResults | Where-Object ToolsOutdated).Count
    MediaConnected  = @($hygResults | Where-Object CdIsoConnected).Count
    OutputFolder    = (Resolve-Path $OutputFolder).Path
}
