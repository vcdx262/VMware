<#
.SYNOPSIS
    Drives a vCenter Server Appliance (VCSA) deployment from a vcsa-deploy JSON template.
.DESCRIPTION
    A parameterized wrapper around VMware's `vcsa-deploy` CLI and the JSON templates in
    this folder. It validates the template with a precheck, optionally runs a full
    install, and reads the appliance root / SSO passwords from environment variables so no
    secret is ever written into the JSON. Logs are collected to a run directory.

    Expected workflow: fill a copy of one of the sample templates (see this folder's
    README), export the passwords, run with -Precheck first, then without.
.PARAMETER Template
    Path to the filled-in vcsa-deploy JSON template.
.PARAMETER InstallerRoot
    Path to the mounted VCSA ISO / extracted installer (contains vcsa-cli-installer).
.PARAMETER LogDir
    Directory for vcsa-deploy logs. Default .\vcsa-logs
.PARAMETER Precheck
    Run template verification only (no deployment).
.EXAMPLE
    $env:VCSA_ROOT_PASSWORD='...'; $env:VCSA_SSO_PASSWORD='...'
    .\Deploy-VCSA.ps1 -Template .\titanvc.json -InstallerRoot E:\ -Precheck
.EXAMPLE
    .\Deploy-VCSA.ps1 -Template .\titanvc.json -InstallerRoot E:\
.NOTES
    Author : Steven Slocum (VCDX #262)
    Notes  : Wraps VMware's vcsa-deploy (shipped on the VCSA ISO). The JSON templates are
             VMware's own samples with lab values; passwords are injected from
             VCSA_ROOT_PASSWORD / VCSA_SSO_PASSWORD at run time, not stored on disk.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(

    [parameter(Mandatory = $true)]
    [string]$Template,

    [parameter(Mandatory = $true)]
    [string]$InstallerRoot,

    [parameter(Mandatory = $false)]
    [string]$LogDir = '.\vcsa-logs',

    [parameter(Mandatory = $false)]
    [switch]$Precheck

)

$ErrorActionPreference = 'Stop'

#Locate the vcsa-deploy binary on the installer media (Windows path shown; adjust for OS)
$deploy = Join-Path $InstallerRoot 'vcsa-cli-installer\win32\vcsa-deploy.exe'
if (-not (Test-Path -LiteralPath $deploy)) {
    throw "vcsa-deploy not found at $deploy — check -InstallerRoot points at the mounted VCSA ISO."
}
if (-not (Test-Path -LiteralPath $Template)) { throw "Template not found: $Template" }
if (-not (Test-Path -LiteralPath $LogDir))   { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

#Inject passwords from the environment into an in-memory copy of the template
$json = Get-Content -Raw -LiteralPath $Template | ConvertFrom-Json
if ($env:VCSA_ROOT_PASSWORD) { $json.new_vcsa.os.password  = $env:VCSA_ROOT_PASSWORD }
if ($env:VCSA_SSO_PASSWORD)  { $json.new_vcsa.sso.password  = $env:VCSA_SSO_PASSWORD }
if ($json.new_vcsa.esxi -and $env:ESXI_PASSWORD) { $json.new_vcsa.esxi.password = $env:ESXI_PASSWORD }

$tmp = Join-Path $env:TEMP ("vcsa-{0}.json" -f (Get-Date -Format yyyyMMddHHmmss))
$json | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $tmp

try {
    if ($Precheck) {
        if ($PSCmdlet.ShouldProcess($Template, 'vcsa-deploy install --precheck-only')) {
            & $deploy install $tmp --accept-eula --acknowledge-ceip --no-esx-ssl-verify --precheck-only --log-dir $LogDir
        }
    }
    else {
        if ($PSCmdlet.ShouldProcess($Template, 'vcsa-deploy install (full)')) {
            & $deploy install $tmp --accept-eula --acknowledge-ceip --no-esx-ssl-verify --log-dir $LogDir
        }
    }
    [pscustomobject]@{ Template = $Template; Mode = $(if ($Precheck) { 'precheck' } else { 'install' }); ExitCode = $LASTEXITCODE; LogDir = (Resolve-Path $LogDir).Path }
}
finally {
    #never leave the password-injected temp copy behind
    Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue
}
