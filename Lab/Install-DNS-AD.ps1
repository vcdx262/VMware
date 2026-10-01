<#
.SYNOPSIS
    Installs DNS + AD DS and promotes a new forest (lab domain controller build).
.DESCRIPTION
    Prompts for the DSRM password, installs the DNS and AD-Domain-Services roles and
    creates a new AD forest with integrated DNS. Run on a fresh Windows Server.
.NOTES
    Author : Steven Slocum
    Notes  : Portfolio copy of a real-world script. Lab values (lab.local, RFC1918)
             and placeholder secrets substituted for any originals.
#>

#Create Secure String

$SecureString = Read-Host -Prompt "DSRM (SafeMode) password" -AsSecureString

#Install DNS Role

Install-WindowsFeature -Name DNS -IncludeManagementTools

#Install AD Role

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

#Install AD Forest

Install-ADDSForest -DomainName lab.local -InstallDNS -SafeModeAdministratorPassword $SecureString -confirm:$false 