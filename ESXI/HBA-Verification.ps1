<#
.SYNOPSIS
    Verifies Emulex HBA presence/status and datastore accessibility per host.
.DESCRIPTION
    For each host in $VMHosts, reports the first four Emulex ("Emu*") HBAs with
    device+status and the first four datastores with state+accessibility. Useful as a
    post-change SAN sanity check. Populate $VMHosts and Connect-VIServer first.
.NOTES
    Author : Steven Slocum
    Notes  : Portfolio copy of a real-world PowerCLI script. Lab values (lab.local,
             RFC1918) and placeholder secrets substituted for any originals.
#>

$datastores = @()
$HBAs = @()
$results = @()


foreach ($d in $VMHosts){


    $vmhost       = get-vmhost -Name $d 
    $hbas         = Get-VMHosthba -VMHost $d |where {$_.model -like "Emu*"}|select VMhost,Device,Status
    $DataStores   = Get-VMHost -Name $d |Get-Datastore |select Name,State,Accessible


     $obj = [PsCustomobject] @{


     VMhost            = $vmhost
     HBA0              = $hbas[0].Device + "|" + $hbas[0].Status
     HBA1              = $hbas[1].Device + "|" + $hbas[1].Status
     HBA2              = $hbas[2].Device + "|" + $hbas[2].Status
     HBA3              = $hbas[3].Device + "|" + $hbas[3].Status
     DataStore0        = $DataStores[0].Name + "|" + $DataStores[0].State + "|" + $DataStores[0].Accessible
     DataStore1        = $DataStores[1].Name + "|" + $DataStores[1].State + "|" + $DataStores[1].Accessible
     DataStore2        = $DataStores[2].Name + "|" + $DataStores[2].State + "|" + $DataStores[2].Accessible
     DataStore3        = $DataStores[3].Name + "|" + $DataStores[3].State + "|" + $DataStores[3].Accessible
 


            }

           $results += $obj 
        }

       

