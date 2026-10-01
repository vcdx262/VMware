<#
.SYNOPSIS
    Reports physical vmnic link state (speed/duplex) per host.
.DESCRIPTION
    For each host in $testhost, collects VMNIC device name, bit rate and duplex and
    assembles a per-host object. Populate $testhost and Connect-VIServer first.
.NOTES
    Author : Steven Slocum
    Notes  : Portfolio copy of a real-world PowerCLI script. Lab values (lab.local,
             RFC1918) and placeholder secrets substituted for any originals.
#>

$NICS = @()
$results = @()


foreach ($t in $testhost){


    $vmhost       = get-vmhost -Name $t
    $nics         = Get-VMHostNetworkAdapter -VMHost $t |where {$_.name -like "VMNIC*"}

     $obj = [PsCustomobject] @{


     VMhost              = $vmhost
     VMNIC0              = $nics[0].DeviceName + "|" + $nics[0].BitRatePerSec + "|" + $nics[0].FullDuplex
     VMNIC1              = $nics[1].DeviceName + "|" + $nics[1].BitRatePerSec + "|" + $nics[1].FullDuplex
     VMNIC4              = $nics[4].DeviceName + "|" + $nics[4].BitRatePerSec + "|" + $nics[4].FullDuplex
     VMNIC5              = $nics[5].DeviceName + "|" + $nics[5].BitRatePerSec + "|" + $nics[5].FullDuplex
     VMNIC2              = $nics[2].DeviceName + "|" + $nics[2].BitRatePerSec + "|" + $nics[2].FullDuplex
     VMNIC3              = $nics[3].DeviceName + "|" + $nics[3].BitRatePerSec + "|" + $nics[3].FullDuplex

 


            }

           $results += $obj 
        }
