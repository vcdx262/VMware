<#
.SYNOPSIS
    Creates vSphere Distributed Switches (VDS) from a CSV definition.
.DESCRIPTION
    For each row in VDS-Config.csv, creates a New-VDSwitch with version, datacenter
    location, uplink count, MTU, link-discovery protocol/operation and contact/notes.
.NOTES
    Author : Steven Slocum
    Notes  : Portfolio copy of a real-world PowerCLI script. Lab values (lab.local,
             RFC1918) and placeholder secrets substituted for any originals.
    Edit the Import-Csv path (VDS-Config.csv) before running; Connect-VIServer first.
#>

$VDSConfig = Import-Csv C:\dev\VDS-Config.csv

foreach ($VDS in $VDSConfig)

    {
        New-VDSwitch -Name $vds.Switchname -Version $vds.Version -Location $vds.vSpherelocation -NumUplinkPorts $vds.UPLinkCount -Mtu $vds.MTU -LinkDiscoveryProtocol $vds.LinkDiscoveryProtocol -LinkDiscoveryProtocolOperation $vds.LinkDiscoveryProtocolOperation -ContactName $vds.contactname -ContactDetails $vds.contactdetails -notes $vds.notes

    
    }

