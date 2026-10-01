<#
.SYNOPSIS
    Inventories Fibre Channel / storage HBAs across every connected vCenter.
.DESCRIPTION
    Iterates all vCenters in $global:DefaultVIServers, enumerates each host's HBAs
    (device, type, model, status, driver, PCI) and exports the result to CSV.
    Connect to one or more vCenters with Connect-VIServer before running.
.OUTPUTS
    CSV of HBA inventory (edit the Export-Csv path before use).
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

                $hbas = (get-vmhosthba -vmhost ($h).name )
                    
                    foreach ($hba in $hbas){

                        $obj = $null
                         
                        $obj =  [pscustomobject] @{
                    
                                vCenter               = $v 
                                VMHost                = $h.name
                                Device                = $hba.Device
                                Type                  = $hba.Type
                                Model                 = $hba.Model
                                Status                = $hba.Status
                                Driver                = $hba.Driver
                                PCI                   = $hba.PCI


                            }

                          $results += $obj

                 }

            }
        }

   $results |export-csv C:\dev\hbas.csv -NoTypeInformation
                                         
               
      