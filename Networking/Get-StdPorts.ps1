<#
.SYNOPSIS
    Reports standard (non-distributed) virtual switch portgroups across vCenters.
.DESCRIPTION
    Iterates all vCenters in $global:DefaultVIServers and, per standard portgroup,
    reports vSwitch, VLAN, NIC-teaming policy/order and promiscuous/MAC/forged-transmit
    security, exporting to CSV. Connect-VIServer first.
.NOTES
    Author : Steven Slocum
    Notes  : Portfolio copy of a real-world PowerCLI script. Lab values (lab.local,
             RFC1918) and placeholder secrets substituted for any originals.
#>

$results = @()
$vcenters = ($global:DefaultVIServers).name

foreach ($v in $vcenters) 

{
        $hosts = (Get-vmhost -Server $v)

        
            foreach ($h in $hosts){

                $stdports = (get-virtualportgroup -vmhost ($h.name) -standard)
                    
                    foreach ($s in $stdports){

                        $obj = $null
                         
                        $obj =  [pscustomobject] @{
                    
                                vCenter               = $v 
                                VMHost                = $h.name
                                PortGroupName         = $s.name
                                vSwitchName           = $s.VirtualSwitchName
                                Vlan                  = $s.Vlanid
                                TeamingPolicy         = $s.ExtensionData.ComputedPolicy.NicTeaming.Policy
                                NicTeamingOrder       = $s.ExtensionData.ComputedPolicy.NicTeaming.NicOrder.ActiveNic -join '|'
                                AllowPromiscuous      = $s.ExtensionData.ComputedPolicy.Security.AllowPromiscuous
                                MacChanges            = $s.ExtensionData.ComputedPolicy.Security.MacChanges
                                ForgedTransmits       = $s.ExtensionData.ComputedPolicy.Security.ForgedTransmits

                            }

                          $results += $obj

                 }

            }
        }

$results | export-csv ./StandardPorts.csv -NoTypeInformation
              
                                         
               
      