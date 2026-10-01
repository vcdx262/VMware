<#
.SYNOPSIS
    Bulk-deploys nested ESXi appliances from an OVF using a CSV of per-VM settings.
.DESCRIPTION
    Prompts for vCenter credentials, imports a CSV (one row per nested host), and for
    each row populates the OVF's guestinfo properties (hostname, IP, mask, gateway,
    DNS, domain, NTP, syslog, password, SSH) and deploys thin-provisioned via Import-VApp.
.PARAMETER vCenterServer
    FQDN/IP of the target vCenter.
.PARAMETER OvfFile
    Path to the nested-ESXi OVF/OVA.
.PARAMETER csv
    Path to the CSV describing the appliances to deploy.
.EXAMPLE
    .\Deploy-NestedESXI.ps1 -vCenterServer vc.lab.local -OvfFile .\NestedESXi.ova -csv .\hosts.csv
.NOTES
    Author : Steven Slocum
    Notes  : Portfolio copy of a real-world PowerCLI script. Lab values (lab.local,
             RFC1918) and placeholder secrets substituted for any originals.
#>

[cmdletbinding()]

param(

[parameter(Mandatory = $true)]
[string]$vCenterServer,

[parameter(Mandatory = $true)]
[string]$OvfFile,

[parameter(Mandatory = $true)]
[string]$csv

)

#creates and zeros variables for later use

$cred                               =               $null
$vms                                =               $null
$ovfconfig                          =               $null 
$vmname                             =               $null
$VMhost                             =               $null
$DataStore                          =               $null
$PortGroup                          =               $null
$IPaddress                          =               $null
$Subnetmask                         =               $null
$DefaultGateway                     =               $null
$DnsServer                          =               $null
$DnsSuffix                          =               $null
$NTP                                =               $null
$Syslog                             =               $null
$Password                           =               $null
$SSH                                =               $null


#launches credential pop up for the user to enter vCenter credentials then stores them into a PowerShell Credential Object for later use
$cred = Get-Credential

#Import a .csv file from the current directory and store in variable vms - each line represents one VM to be deployed
$vms = import-csv $csv

#Connect to the vCenter server specified in the vCenterServer mandatory parameter
connect-viserver -Server $vCenterServer -Credential $cred -force




#loop through the elements in $vms variable to populate PowerShell variables, retreive OSCustomizationSpec from vCenter, Modify VM network settings for the tmp spec, then deploy from template
foreach ($v in $vms)

    {
        $ovfconfig                          =               $null   
        $vmname                             =               $null
        $VMhost                             =               $null
        $DataStore                          =               $null
        $PortGroup                          =               $null
        $IPaddress                          =               $null
        $Subnetmask                         =               $null
        $DefaultGateway                     =               $null
        $DnsServer                          =               $null
        $DnsSuffix                          =               $null
        $NTP                                =               $null
        $Syslog                             =               $null
        $Password                           =               $null
        $SSH                                =               $null



            $vmname                             =               $v.VmName
            $VMhost                             =               $v.Location
            $DataStore                          =               $v.DataStore
            $PortGroup                          =               $v.PortGroup
            $IPaddress                          =               $v.IPaddress
            $Subnetmask                         =               $v.SubnetMask
            $DefaultGateway                     =               $v.DefaultGateway 
            $DnsServer                          =               $v.DnsServer
            $DnsSuffix                          =               $v.DnsSuffix
            $NTP                                =               $v.NTP 
            $Syslog                             =               $v.Syslog 
            $Password                           =               $v.Password     
            $SSH                                =               $v.SSH 


            #Retrieve OVFConfiguartion from user specified OVFfile
            $ovfconfig = Get-OvfConfiguration $ovffile


            #Populate user supplied parameters into ovfconfig variable
            $ovfconfig.NetworkMapping.VM_Network.value                  = $PortGroup 
            $ovfconfig.common.guestinfo.hostname.value                  = $vmname
            $ovfconfig.common.guestinfo.ipaddress.value                 = $ipaddress
            $ovfconfig.common.guestinfo.netmask.value                   = $Subnetmask
            $ovfconfig.common.guestinfo.gateway.value                   = $DefaultGateway
            $ovfconfig.common.guestinfo.dns.value                       = $DnsServer
            $ovfconfig.common.guestinfo.domain.value                    = $DnsSuffix
            $ovfconfig.common.guestinfo.ntp.value                       = $NTP  
            $ovfconfig.common.guestinfo.syslog.value                    = $Syslog
            $ovfconfig.common.guestinfo.password.value                  = $Password
            $ovfconfig.common.guestinfo.ssh.value                       = $SSH

    #Creates VM from OVFFile and OVFConfig
    Import-VApp -Source $ovffile -OvfConfiguration $ovfconfig -Name $vmname -Vmhost titan1-esx.lab.local -Datastore $datastore -DiskStorageFormat thin -force

}