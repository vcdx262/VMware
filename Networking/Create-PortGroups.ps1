<#
.SYNOPSIS
    Creates distributed portgroups and sets uplink teaming from a CSV.
.DESCRIPTION
    For each row in PortGroups.csv, creates a VD portgroup (name, VDS, VLAN) then
    applies an active/standby/unused uplink teaming policy and load-balancing policy,
    branching on which uplink sets are populated.
.NOTES
    Author : Steven Slocum
    Notes  : Portfolio copy of a real-world PowerCLI script. Lab values (lab.local,
             RFC1918) and placeholder secrets substituted for any originals.
    Edit the Import-Csv path (PortGroups.csv) before running; Connect-VIServer first.
#>

#Import inputs from CSV file
$inputs = import-csv C:\dev\PortGroups.csv

    #loop over input collection
    foreach ($i in $inputs)

        {

            #Populate variables
            $portgroupname        = $i.portgroupname
            $vds                  = $i.VDSName
            $vlan                 = $i.vlan
            $ActiveUplinks        = @(foreach ($al in ($i.ActiveUplinks.split(','))) {'dvUplink' + $al})
            $StandbyUplinks       = @(foreach ($sl in ($i.StandbyUplinks.split(','))) {'dvUplink' + $sl})
            $UnusedUplinks        = @(foreach ($ul in ($i.UnusedUplinks.split(','))) {'dvUplink' + $ul})
            $LoadBalancingPolicy  = $i.LoadBalancingPolicy

            #Create PortGroups
            New-VDPortgroup -VDSwitch $vds -Name $portgroupname -VlanId $vlan


            #Perform length checks on uplink variables and determine which statement to use
            #Retrive PortGroup then PortGroup Teaming Policy and set desired state

            if ($StandbyUplinks[0].Length -gt 8 -and $UnusedUplinks.Length -gt 8)

                {
                 Get-VDPortgroup -name $portgroupname | Get-VDUplinkTeamingPolicy | Set-VDUplinkTeamingPolicy -ActiveUplinkPort $ActiveUplinks -StandbyUplinkPort $StandbyUplinks -UnusedUplinkPort $UnusedUplinks -LoadBalancingPolicy $LoadBalancingPolicy
                }

                    elseif ($StandbyUplinks[0].Length -gt 8 -and $UnusedUplinks[0].Length -le 8)
                    {
                     Get-VDPortgroup -name $portgroupname | Get-VDUplinkTeamingPolicy | Set-VDUplinkTeamingPolicy -ActiveUplinkPort $ActiveUplinks -StandbyUplinkPort $StandbyUplinks -LoadBalancingPolicy $LoadBalancingPolicy
                    }

                        elseif ($StandbyUplinks[0].Length -le 8 -and $UnusedUplinks[0].Length -gt 8)
                        {
                        Get-VDPortgroup -name $portgroupname | Get-VDUplinkTeamingPolicy | Set-VDUplinkTeamingPolicy -ActiveUplinkPort $ActiveUplinks -UnusedUplinkPort $UnusedUplinks -LoadBalancingPolicy $LoadBalancingPolicy
                        }

                            else
                            {
                            Get-VDPortgroup -name $portgroupname | Get-VDUplinkTeamingPolicy | Set-VDUplinkTeamingPolicy -ActiveUplinkPort $ActiveUplinks -LoadBalancingPolicy $LoadBalancingPolicy
                            }

        }