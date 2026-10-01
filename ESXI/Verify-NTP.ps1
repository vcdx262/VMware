<#
.SYNOPSIS
    Reports ESXi NTP (ntpd) service policy and running state per host.
.DESCRIPTION
    For each host in $VMHosts, reads the ntpd service label, policy, running and
    required state, exports to CSV and shows it in Out-GridView. Connect-VIServer first.
.NOTES
    Author : Steven Slocum
    Notes  : Portfolio copy of a real-world PowerCLI script. Lab values (lab.local,
             RFC1918) and placeholder secrets substituted for any originals.
#>

foreach ($a in $VMHosts)
        
        {


            $ntpresults = foreach ($b in $VMHosts) {get-vmhost $b | Get-VMHostService | Where-Object {$_.key -eq "ntpd"} | select vmhost, label, Key, Policy, Running, Required}
            $ntpresults | export-csv ./NtpResults.csv
            $ntpresults |ogv

            }