<#
.SYNOPSIS
    Creates vMotion VMkernel adapters on hosts from a CSV-driven collection.
.DESCRIPTION
    For each row in $vmotion (populate from Import-Csv first), adds a VMkernel NIC on
    the host's second TCP/IP stack with the given portgroup, MTU, IP, mask and vSwitch.
.NOTES
    Author : Steven Slocum
    Notes  : Portfolio copy of a real-world PowerCLI script. Lab values (lab.local,
             RFC1918) and placeholder secrets substituted for any originals.
#>

foreach ($v in $vmotion)
        
        {
            $vmhost = (Get-VMHost -Name $v.Hostname)
        
            $stack = (Get-VMHostNetworkStack -VMHost $vmhost)[1]

            New-VMHostNetworkAdapter -VMHost $vmhost -PortGroup $v.portgroup -Mtu $v.mtu -IP $v.ip -SubnetMask $v.subnetmask -VirtualSwitch $v.vswitch -NetworkStack $stack

            }



