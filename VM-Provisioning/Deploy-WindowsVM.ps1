<#
.SYNOPSIS
    Bulk-deploys Windows VMs from a template using per-VM OS customization specs.
.DESCRIPTION
    Imports a CSV (one row per VM), clones a vCenter OS Customization Spec into a temp
    spec, applies per-VM IPv4/IPv6 settings (static or DHCP, address/mask/gateway and up
    to two DNS servers each) and NIC mapping, then deploys from the named template onto
    the chosen cluster/host/datastore. The Windows CSV uses four DNS fields
    (IPv4Dns1/2, IPv6Dns1/2).
.PARAMETER vCenterServer
    FQDN/IP of the target vCenter.
.PARAMETER csv
    Path to the per-VM deployment CSV.
.EXAMPLE
    .\Deploy-WindowsVM.ps1 -vCenterServer vc.lab.local -csv .\windows-vms.csv
.NOTES
    Author : Steven Slocum
    Notes  : Portfolio copy of a real-world PowerCLI script. Lab values and
             placeholder secrets substituted for any originals.
    Requires an existing vCenter template and OS customization spec.
#>

[cmdletbinding()]

param(

[parameter(Mandatory = $true)]
[string]$vCenterServer,

[parameter(Mandatory = $true)]
[string]$csv

)

#creates and zeros variables for later use

$cred                               =               $null
$vms                                =               $null
$VmName                             =               $null
$cluster                            =               $null
$portgroup                          =               $null
$clusterhosts                       =               $null
$deploymenthost                     =               $null
$location                           =               $null
$datastore                          =               $null
$template                           =               $null
$IPv4IPAddress                      =               $null
$IPv4SubnetMask                     =               $null
$IPv4DefaultGateway                 =               $null
$IPv4Dns1                           =               $null
$IPv4Dns2                           =               $null
$IPv6DHCPSet                        =               $null
$IPv6Object                         =               $null
$IPv6AddressSpecObject              =               $null
$IPv6IPAddress                      =               $null
$IPv6SubnetMask                     =               $null
$IPv6DefaultGateway                 =               $null
$IPv6Dns1                           =               $null
$IPv6Dns2                           =               $null
$SpecName                           =               $null
$tmpspec                            =               $null
$nicmapping                         =               $null



#launches credential pop up for the user to enter vCenter credentials then stores them into a PowerShell Credential Object for later use
$cred = Get-Credential

#Import a .csv file from the current directory and store in variable vms - each line represents one VM to be deployed
$vms = import-csv $csv

#Connect to the vCenter server specified in the vCenterServer mandatory parameter
connect-viserver -Server $vCenterServer -Credential $cred -force




#loop through the elements in $vms variable to populate PowerShell variables, retreive OSCustomizationSpec from vCenter, Modify VM network settings for the tmp spec, then deploy from template
foreach ($v in $vms)

    {

    $VmName                             =               $null
    $cluster                            =               $null
    $portgroup                          =               $null
    $clusterhosts                       =               $null
    $deploymenthost                     =               $null
    $location                           =               $null
    $datastore                          =               $null
    $template                           =               $null
    $IPv4IPAddress                      =               $null
    $IPv4SubnetMask                     =               $null
    $IPv4DefaultGateway                 =               $null
    $IPv4Dns1                           =               $null
    $IPv4Dns2                           =               $null
    $IPv6DHCPSet                        =               $null
    $IPv6Object                         =               $null
    $IPv6AddressSpecObject              =               $null
    $IPv6IPAddress                      =               $null
    $IPv6SubnetMask                     =               $null
    $IPv6DefaultGateway                 =               $null
    $IPv6Dns1                           =               $null
    $IPv6Dns2                           =               $null
    $SpecName                           =               $null
    $tmpspec                            =               $null
    $nicmapping                         =               $null



    $VmName                             =           $v.VmName
    $cluster                            =           $v.cluster
    $portgroup                          =           $v.portgroup    
    $clusterhosts                       =           (get-vmhost -location $cluster)
    $deploymenthost                     =           ($clusterhosts[0])
    $location                           =           $v.location 
    $datastore                          =           $v.datastore  
    $template                           =           $v.template
    [int32]$IPv4DHCP                    =           $v.IPv4DHCP                    
    [int32]$IPv6DHCP                    =           $v.IPv6DHCP
    $SpecName                           =           $v.SpecName
    $tmpspec                            =           (Get-OSCustomizationSpec $SpecName |New-OSCustomizationSpec -Name TMP -Type NonPersistent)
    $nicmapping                         =           ($tmpspec | Get-OSCustomizationNicMapping)
    $IPv6AddressSpecObject              =           New-Object VMware.Vim.CustomizationIPSettingsIpV6AddressSpec
    $Ipv6Object                         =           New-Object VMware.Vim.CustomizationFixedIpV6

    #Tests to see if any DNS servers are manually specified, if so it sets them in type cast variables   
    if ($v.IPv6Dns1.Length -gt 0)

        {
            [ipaddress]$IPv6Dns1                                     =           $v.IPv6Dns1 
        }

    if ($v.IPv6Dns2.Length -gt 0)

        {
            [ipaddress]$IPv6Dns2                                     =           $v.IPv6Dns2 
        } 

    if ($v.IPv4Dns1.Length -gt 0)

        {
            [ipaddress]$IPv4Dns1                                     =           $v.IPv4Dns1 
        }

    if ($v.IPv4Dns2.Length -gt 0)

        {
            [ipaddress]$IPv4Dns2                                     =           $v.IPv4Dns2 
        }



    #Tests to determine if a boolean value equaling true is set for $IPv6DHCP and that a value is present for static IPv6 address, if both are detected, the script warns and exits
    if (($IPv6DHCP -eq $true) -and ($v.IPv6IPAddress.Length -gt 0))

        {
                Write-Warning "IPv6DHCP and Static address both set for $vmname - please use only one"
                Get-OSCustomizationSpec TMP |Remove-OSCustomizationSpec -Confirm:$false
                Exit

        }

            #Tests that if IPv6DHCP is not set then some value other than null is set for IPv6IPaddress
            elseif (($IPv6DHCP -eq $false) -and ($v.IPv6IPAddress.Length -eq 0)) 
            {
                write-warning "IPv6 DHCP is disabled and no static IP is assigned for $VmName - Enable DHCP or specify a static IP"
                Get-OSCustomizationSpec TMP |Remove-OSCustomizationSpec -Confirm:$false
                exit 
            }


            #Tests that IPv6Subnet mask is a value between 1-128 OR null, any other condition warns then cleans up TMP spec and exits
            elseif (($v.IPv6SubnetMask -notin 1..128) -and ($v.IPv6SubnetMask.Length -ne 0)) 
            {
                write-warning "Invalid IPv6 Subnet Mask Specified for $VmName - IPv6 CIDR range 1 - 128"
                Get-OSCustomizationSpec TMP |Remove-OSCustomizationSpec -Confirm:$false
                exit 
            }


            #Tests that boolean value equaling true is set for IPv6DHCP, if detected as true inserts IPv6DHCPSet object into ExtensionData.Adapter.IpV6Spec.Ip `
            # And sets ExtensionData.Adapter.IpV6Spec.Gateway to $null
            elseif ($IPv6DHCP -eq $true)

            {
            $IPv6DHCPSet                                                =           New-Object VMware.Vim.CustomizationDhcpIpV6Generator
            $nicmapping.ExtensionData.Adapter.IpV6Spec.Ip               =           $IPv6DHCPSet
            $nicmapping.ExtensionData.Adapter.IpV6Spec.Gateway          =           $null
            $tmpspec | Get-OSCustomizationNicMapping |Set-OSCustomizationNicMapping -Dns $IPv4Dns1,$IPv4Dns2,$IPv6Dns1,$IPv6Dns2              
            }

                #Sets values for static IPv6 address if no other tests are matched
                 else   {
                        [ipaddress]$IPv6IPAddress                                   =           $v.IPv6IPAddress
                        [int32]$IPv6SubnetMask                                      =           $v.IPv6SubnetMask
                        [ipaddress]$IPv6DefaultGateway                              =           $v.IPv6DefaultGateway
                        $IPv6Object.IpAddress                                       =           $IPv6IPAddress
                        $IPv6Object.SubnetMask                                      =           $IPv6SubnetMask
                        $IPv6AddressSpecObject.Ip                                   =           $Ipv6Object
                        $IPv6AddressSpecObject.Gateway                              =           $IPv6DefaultGateway
                        $nicmapping.ExtensionData.Adapter.IpV6Spec                  =           $IPv6AddressSpecObject
                        $tmpspec | Get-OSCustomizationNicMapping |Set-OSCustomizationNicMapping -Dns $IPv4Dns1,$IPv4Dns2,$IPv6Dns1,$IPv6Dns2
                        }

    #Tests to determine if a boolean value equaling true is set for $IPv4DHCP and that a value is present for static IPv4 address, if both are detected, the script warns and exits
    if (($IPv4DHCP -eq $true) -and ($IPv4IPAddress.Length -gt 0))

    {
            Write-Warning "IPv4DHCP and Static address both set for $vmname - please use only one"
            Get-OSCustomizationSpec TMP |Remove-OSCustomizationSpec -Confirm:$false
            Exit

    }

        #Tests that if IPv4DHCP is not set then some value other than null is set for IPv4IPaddress
        elseif (($IPv4DHCP -eq $false) -and ($v.IPv4IPAddress.Length -eq 0)) 
        {
            write-warning "IPv4 DHCP is disabled and no static IP is assigned for $VmName - Enable DHCP or specify a static IP"
            Get-OSCustomizationSpec TMP |Remove-OSCustomizationSpec -Confirm:$false
            exit 
        }

        #Tests that boolean value equaling true is set for IPv4DHCP, if detected as true sets -IpMode to UseDHCP for the NicMapping Spec
        elseif ($IPv4DHCP -eq $true)
    
        {
            $tmpspec |Get-OSCustomizationNicMapping |Set-OSCustomizationNicMapping -IpMode UseDhcp -Dns $IPv4Dns1,$IPv4Dns2,$IPv6Dns1,$IPv6Dns2
    
        }
    
             else   {
                    #Re-configures the customization spec stored in the $tmpSpec variable with the IP settings retrieved from vms.csv for IP, Subnet, Gateway, DNS, etc.
                    [IpAddress]$IPv4IPAddress                               =           $v.IPv4IPAddress 
                    [ipaddress]$IPv4SubnetMask                              =           $v.IPv4Subnetmask 
                    [ipaddress]$IPv4DefaultGateway                          =           $v.IPv4DefaultGateway
                    $tmpspec | Get-OSCustomizationNicMapping |Set-OSCustomizationNicMapping `
                    -IpAddress $IPv4IPAddress `
                    -IpMode UseStaticIP `
                    -SubnetMask $IPv4SubnetMask `
                    -DefaultGateway $IPv4DefaultGateway `
                    -Dns $IPv4Dns1,$IPv4Dns2,$IPv6Dns1,$IPv6Dns2
                    }


    #Issues New-VM command to $vCenterServer with all correct variable input retrieved from vms.csv
    New-VM -Server $vCenterServer -Name $VmName -Template $template -OSCustomizationSpec $tmpspec -VMHost $deploymenthost -Datastore $datastore -NetworkName $PortGroup -Location $location
   
    Start-Sleep -Seconds 60
    
    get-vm $VmName |Start-VM

    Get-OSCustomizationSpec TMP |Remove-OSCustomizationSpec -Confirm:$false

}