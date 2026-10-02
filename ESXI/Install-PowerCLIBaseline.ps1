<#
.SYNOPSIS
    Installs VMware PowerCLI and applies a consistent, non-interactive baseline.
.DESCRIPTION
    Installs (or updates) the VMware.PowerCLI module for the current user and sets the
    configuration that makes automation predictable and quiet:
      - CEIP participation off (unattended)
      - Invalid/self-signed certificate action configurable (default: Ignore, for labs)
      - Single default VIServer mode (avoids ambiguous multi-server state)
    Reports the installed PowerCLI version and the resulting configuration.
.PARAMETER CertificateAction
    InvalidCertificateAction for PowerCLI: Ignore (lab default), Warn, Fail, Prompt or
    Unset. Use Fail/Warn with trusted CA-signed vCenter certs in production.
.PARAMETER Scope
    Module install scope: CurrentUser (default) or AllUsers (needs elevation).
.EXAMPLE
    .\Install-PowerCLIBaseline.ps1 -WhatIf
.EXAMPLE
    .\Install-PowerCLIBaseline.ps1 -CertificateAction Warn
.NOTES
    Author : Steven Slocum (VCDX #262)
    Notes  : Replaces per-session certificate hacks with a durable PowerCLI config.
             Default CertificateAction=Ignore is for labs; prefer Warn/Fail in production.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(

    [parameter(Mandatory = $false)]
    [ValidateSet('Ignore', 'Warn', 'Fail', 'Prompt', 'Unset')]
    [string]$CertificateAction = 'Ignore',

    [parameter(Mandatory = $false)]
    [ValidateSet('CurrentUser', 'AllUsers')]
    [string]$Scope = 'CurrentUser'

)

$ErrorActionPreference = 'Stop'

#Install or update PowerCLI
if (-not (Get-Module -ListAvailable VMware.PowerCLI)) {
    if ($PSCmdlet.ShouldProcess('VMware.PowerCLI', "Install module ($Scope)")) {
        Install-Module -Name VMware.PowerCLI -Scope $Scope -Force -AllowClobber
    }
}
else {
    if ($PSCmdlet.ShouldProcess('VMware.PowerCLI', 'Update module')) {
        Update-Module -Name VMware.PowerCLI -ErrorAction SilentlyContinue
    }
}

Import-Module VMware.PowerCLI -ErrorAction Stop

#Apply baseline configuration (scope = session + user)
if ($PSCmdlet.ShouldProcess('PowerCLI configuration', 'Apply baseline')) {
    Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -Confirm:$false | Out-Null
    Set-PowerCLIConfiguration -Scope User -InvalidCertificateAction $CertificateAction -Confirm:$false | Out-Null
    Set-PowerCLIConfiguration -Scope User -DefaultVIServerMode Single -Confirm:$false | Out-Null
}

$ver = (Get-Module -ListAvailable VMware.PowerCLI | Sort-Object Version -Descending | Select-Object -First 1).Version
$cfg = Get-PowerCLIConfiguration -Scope User

[pscustomobject]@{
    PowerCLIVersion        = $ver
    CEIP                   = $cfg.ParticipateInCEIP
    InvalidCertificateAction = $cfg.InvalidCertificateAction
    DefaultVIServerMode    = $cfg.DefaultVIServerMode
}
