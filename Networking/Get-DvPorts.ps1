<#
.SYNOPSIS
    Reports distributed-switch portgroup security/teaming/LACP settings.
.DESCRIPTION
    For each host in $hosts, emits host/ESXi/model/CPU plus the DVS default port
    config: teaming inheritance, LACP, port count, binding, promiscuous/MAC-change/
    forged-transmit security and IPFIX. Exports to CSV. Connect-VIServer first.
.NOTES
    Author : Steven Slocum
    Notes  : Portfolio copy of a real-world PowerCLI script. Lab values (lab.local,
             RFC1918) and placeholder secrets substituted for any originals.
#>

$results = @()
foreach ($h in $hosts){

                $obj = $null
                         
                $obj =  [pscustomobject] @{
                    
                        Host                  = $h 
                        ESXI                  = $h.ExtensionData.Config.Product.Fullname
                        Model                 = $h.model
                        CPU                   = $g.numcpu
                        Processor             = $h.ProcessorType
                        TeamPolicyInherited   = $p.ExtensionData.Config.DefaultPortConfig.UplinkTeamingPolicy.Inherited
                        LACP                  = $p.ExtensionData.Config.DefaultPortConfig.LacpPolicy.Enable.Value
                        NumberOfPorts         = $p.NumPorts
                        ISUplink              = $p.isuplink
                        PortBinding           = $p.PortBinding
                        AllowPromiscuous      = $p.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.AllowPromiscuous.Value
                        MacChanges            = $p.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.MacChanges.Value
                        ForgedTransmits       = $p.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.ForgedTransmits.Value
                        IPFixEnabled          = $p.ExtensionData.Config.DefaultPortConfig.IpfixEnabled.Value


                        

                        }

                $results += $obj
                                         
                    }
                
}

$results | export-csv ./StandardPorts.csv -NoTypeInformation