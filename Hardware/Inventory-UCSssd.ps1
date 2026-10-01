<#
.SYNOPSIS
    Inventories SSD health stats per Cisco UCS service profile.
.DESCRIPTION
    Connects to a UCS Manager domain (Cisco UCS PowerTool), enumerates assigned
    service profiles and correlates each with its SSD health statistics.
.PARAMETER ucs
    UCS Manager hostname/VIP. Prompts for credentials at runtime.
.NOTES
    Author : Steven Slocum
    Notes  : Portfolio copy of a real-world script. Lab values (lab.local, RFC1918)
             and placeholder secrets substituted for any originals.
#>

[cmdletbinding()]

#Define Input and Output Parameters
param(

[parameter(Mandatory = $true)]
[string]$ucs

)

Set-UcsPowerToolConfiguration -SupportMultipleDefaultUcs $True

$cred =  get-credential

Disconnect-Ucs

connect-ucs -name $ucs -Credential $cred


Import-Module Cisco.UCSManager


$drives              = $null
$results             = $null
$profile             = $null
$stats               = $null
$servername          = $null
$ProfileRackUnit     = $null
$ssdstats            = $null

$results             = @()
$profile             = Get-UCSServiceProfile -ucs $ucs | where {$_.AssignState -eq "assigned"}
$ssdstats            = Get-UCSStoragessdHealthStats -ucs $ucs


foreach ($p in $profile)

{
            $obj                 = $null
            $ServerName          = $p.name
            $ProfileRackUnit     = $p.pndn
            $drives  = $ssdstats | Where {$_.dn.Substring(0,16) -eq ($ProfileRackUnit)}
                 

                                
                foreach ($d in $drives){
                        
                $obj = [PsCustomobject] @{

                UCS                     = $ucs
                ServerName              = $servername
                ProfileRackUnit         = $ProfileRackUnit
                SSDRackUnit             = $d.dn.Substring(0,16)
                SSDStorageBUS           = $d.dn.Substring(23, 13)
                SSDDiskID               = $d.dn.Substring(37, 7).trimend("/")
                SSDPercentLifeLeft      = $d.PercentageLifeLeft
                }
                    

                    
                                

        $results += $obj

                }
    


    
}

        $results  | ogv