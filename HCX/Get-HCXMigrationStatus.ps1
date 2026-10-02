<#
.SYNOPSIS
    Reports VMware HCX migration status via the HCX REST API.
.DESCRIPTION
    Authenticates to an HCX Connector/Manager, pulls the current migration set and reports
    one row per migration: VM name, migration type (bulk / vMotion / RAV / cold),
    state/progress, source and destination, and start time. Flags migrations in a failed
    or stalled state. Read-only.
.PARAMETER HcxServer
    HCX Manager / Connector FQDN or IP.
.PARAMETER Credential
    HCX credentials. Prompted if omitted.
.PARAMETER Path
    Output CSV path. Default .\HCX-Migrations.csv
.EXAMPLE
    .\Get-HCXMigrationStatus.ps1 -HcxServer hcx.lab.local
.NOTES
    Author : Steven Slocum (VCDX #262)
    Notes  : Requires PowerShell 7+ (uses -SkipCertificateCheck for the HCX self-signed
             cert). Uses the HCX public REST API (hybridity/api). Read-only.
#>

[CmdletBinding()]
param(

    [parameter(Mandatory = $true)]
    [string]$HcxServer,

    [parameter(Mandatory = $false)]
    [pscredential]$Credential,

    [parameter(Mandatory = $false)]
    [string]$Path = '.\HCX-Migrations.csv'

)

$ErrorActionPreference = 'Stop'
if (-not $Credential) { $Credential = Get-Credential -Message "HCX ($HcxServer) credentials" }

$base = "https://$HcxServer"

#Authenticate — HCX returns a session token in the x-hm-authorization header
$authBody = @{ username = $Credential.UserName; password = $Credential.GetNetworkCredential().Password } | ConvertTo-Json
$authResp = Invoke-WebRequest -Method Post -SkipCertificateCheck `
    -Uri "$base/hybridity/api/sessions" -ContentType 'application/json' -Body $authBody
$token = $authResp.Headers['x-hm-authorization']
if (-not $token) { throw "HCX authentication to $HcxServer did not return a session token." }
$headers = @{ 'x-hm-authorization' = $token; 'Accept' = 'application/json' }

#Query the migration set
$query = @{ filter = @{ state = @() } } | ConvertTo-Json -Depth 5
$resp  = Invoke-RestMethod -Method Post -SkipCertificateCheck `
    -Uri "$base/hybridity/api/migrations?action=query" -Headers $headers -ContentType 'application/json' -Body $query

$results = @()
foreach ($m in $resp.items) {
    $obj = $null
    $obj = [pscustomobject]@{
        VM            = $m.migrationInfo.entityDetails.entityName
        Type          = $m.migrationInfo.migrationType
        State         = $m.migrationInfo.progressDetails.currentOperation
        ProgressPct   = $m.migrationInfo.progressDetails.progressPercentage
        Source        = $m.migrationInfo.source.endpointName
        Destination   = $m.migrationInfo.destination.endpointName
        StartTime     = $m.migrationInfo.startTime
        Failed        = ($m.migrationInfo.progressDetails.currentOperation -match 'FAIL|ERROR')
    }
    $results += $obj
}

$results | Export-Csv -Path $Path -NoTypeInformation

$failed = @($results | Where-Object Failed)
if ($failed.Count -gt 0) { Write-Warning "$($failed.Count) HCX migration(s) in a failed/error state." }

Write-Verbose "Wrote $($results.Count) migrations to $Path"
$results
