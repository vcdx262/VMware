<#
.SYNOPSIS
    Inventories SCSI LUNs (incl. SSD / vSAN state) across every connected vCenter.
.DESCRIPTION
    Iterates all vCenters in $global:DefaultVIServers and reports per-LUN display
    name, vendor/model, type, capacity, locality, SSD flag, multipath policy and
    queue depth; exports to SCSILuns.csv. Connect with Connect-VIServer first.
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

                $scsiluns = (get-scsilun -vmhost ($h.name) )
                    
                    foreach ($s in $scsiluns){

                        $obj = $null
                         
                        $obj =  [pscustomobject] @{
                    
                                vCenter               = $v 
                                VMHost                = $h.name
                                DisplayName           = $s.ExtensionData.DisplayName
                                Vendor                = $s.vendor
                                Model                 = $s.model
                                LunType               = $s.luntype
                                CapacityGB            = $s.CapacityGB
                                IsLocal               = $s.islocal
                                IsSSD                 = $s.IsSSD
                                MultiPathPolicy       = $s.MultipathPolicy
                                CommandsToSwitchPathy = $s.CommandsToSwitchPath
                                BlocksToSwitchPath    = $s.BlocksToSwitchPath
                                QueueDepth            = $s.ExtensionData.QueueDepth
                                VSANStatus            = $s.vsanstatus
                            }

                          $results += $obj

                 }

            }
        }

$results | export-csv ./SCSILuns.csv -NoTypeInformation
              
                                         
               
      