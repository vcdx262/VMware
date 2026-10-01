<#
.SYNOPSIS
    Collects a wide ESXi host configuration baseline and exports it to CSV.
.DESCRIPTION
    Reads a text file of host names and, per host, gathers syslog, NTP (service+servers),
    SNMP, VMkernel adapters, VDS membership, datastores and Storage I/O Control, LUNs,
    HBAs, DNS, the default/vMotion TCP-IP stacks and host authentication (AD) settings,
    writing one row per host. Intended as a pre/post-change configuration audit.
.PARAMETER InputFile
    Text file with one ESXi host name per line.
.PARAMETER OutputFile
    Destination CSV path.
.EXAMPLE
    .\Verify-Hosts.ps1 -InputFile .\hosts.txt -OutputFile .\baseline.csv
.NOTES
    Author : Steven Slocum
    Notes  : Portfolio copy of a real-world PowerCLI script. Lab values (lab.local,
             RFC1918) and placeholder secrets substituted for any originals.
#>

[cmdletbinding()]

#Define Input and Output Parameters
param(

[parameter(Mandatory = $true)]
[string]$InputFile,

[parameter(Mandatory = $true)]
[string]$OutputFile

)

#Create Empty Array called Results
$results = @()



$allhosts = (get-content $InputFile)


foreach ($a in $allhosts)
        
        {


#Zeroing or Nulling all variables to be used in the loop 

        $vmhost                             = $null
        $esxcli                             = $null
        $SyslogServer                       = $null
        $NTPServers                         = $null
        $NTPString                          = $null
        $NTPService                         = $null
        $NTPStartType                       = $null
        $NTPRunning                         = $null
        $SNMP                               = $null
        $SNMPCommunities                    = $null
        $SNMPStrings                        = $null
        $SnmpPort                           = $null
        $SNMPReceiver                       = $null
        $vmk0                               = $null
        $vmk1                               = $null
        $vmk2                               = $null
        $vmk3                               = $null
        $vmk4                               = $null
        $vds0                               = $null
        $vds1                               = $null
        $HostDataStores                     = $null
        $DataStoreString                    = $null
        $DSCluster                          = $null
        $DSClusterString                    = $null
        $Ds1SIOCEnabled                     = $null
        $Ds2SIOCEnabled                     = $null
        $Ds3SIOCEnabled                     = $null
        $Ds4SIOCEnabled                     = $null
        $Ds1StatsCollected                  = $null
        $Ds2StatsCollected                  = $null
        $Ds3StatsCollected                  = $null
        $Ds4StatsCollected                  = $null
        $luns                               = $null
        $lun1                               = $null
        $lun2                               = $null
        $HBAs                               = $null
        $hba1                               = $null
        $hba2                               = $null
        $DefaultStack                       = $null
        $DnsString                          = $null
        $DnsServerString                    = $null
        $VmotionStack                       = $null
        $Authentication                     = $null
        $TrustedDomains                     = $null
        $DomainString                       = $null
        $AdminGroups                        = $null
        $nics                               = $null
        $VMnic0String                       = $null 
        $VMnic1String                       = $null 
        $VMnic2String                       = $null 
        $VMnic3String                       = $null 
        $VMnic4String                       = $null 
        $VMnic5String                       = $null
        $FailBackdelay                      = $null




#Get vSphere host object into variable 

            $vmhost          = (get-vmhost $a)

#Get esxcli command shellf for current host

            $esxcli          = get-esxcli -vmhost $a

#Retrieve and store current host syslog server     

            $SyslogServer    = Get-VMHostSysLogServer -VMHost $vmhost

#Retrieve and store current host NTP Servers into NTPservers variable


            $NTPServers      = Get-VMHostNtpServer -VMHost $vmhost

#Retrive and concatenate up to three NTP servers from NTPServers variable

                if ($NTPServers.count -gt '0')

                    {
                    $NTPString = ($NTPServers[0] + '|' + $NTPServers[1] + '|' + $NTPServers[2]).TrimEnd("|")
                    }
            
#Retrive and store NTP service settings for current host into several variables

            $NTPService      = ($vmhost | Get-VMHostService |Where-Object {$_.key -eq "ntpd"})
            $NTPStartType    = $NTPService.Policy
            $NTPRunning      = $NTPService.Running

#Retrive and store SNMP service settings for current host into several variables

            $SNMP            = $esxcli.system.snmp.get()
                if ($snmp.count -gt '0')

                {
                $SnmpPort        = $snmp.port
                $SnmpReceiver    = $snmp.syslocation
                $SnmpCommunities = $snmp.communities
                }

                if ($SNMPCommunities -gt '0')

                {
                $SNMPStrings = ($snmp.communities[0] + "|" + $snmp.communities[1] + "|" + $snmp.communities[2]).TrimEnd("|")
                }


#Retrive and VMkernel and VDS settings for current host into several variables

            $vmk0            = (Get-VMHostNetworkAdapter -VMHost $vmhost | Where-Object {$_.DeviceName -eq "vmk0"})
            $vmk1            = (Get-VMHostNetworkAdapter -VMHost $vmhost | Where-Object {$_.DeviceName -eq "vmk1"})
            $vmk2            = (Get-VMHostNetworkAdapter -VMHost $vmhost | Where-Object {$_.DeviceName -eq "vmk2"})
            $vmk3            = (Get-VMHostNetworkAdapter -VMHost $vmhost | Where-Object {$_.DeviceName -eq "vmk3"})
            $vmk4            = (Get-VMHostNetworkAdapter -VMHost $vmhost | Where-Object {$_.DeviceName -eq "vmk4"})
            $vds             = (Get-VDSwitch -VMHost $vmhost)
                
                if ($vds.count -gt '0') 
                
                    {
                $vds0            = (Get-VDSwitch -VMHost $vmhost)[0]
                $vds1            = (Get-VDSwitch -VMHost $vmhost)[1]
                    }

     
            

#Retrive and store Datastores for current host into HostDataStore variable

            $HostDataStores  = ($vmhost | get-datastore)


#Verify HostDataStore variable contains objects and concatenate results into DataStoreString variable

                if ($HostDataStores.count -gt '0')

                    {
                    $DataStoreString = ($HostDataStores[0].name + "|" + $HostDataStores[1].name + "|" + $HostDataStores[2].name + "|" + $HostDataStores[3].name + "|" + $HostDataStores[4].name + "|" +  $HostDataStores[5].name).TrimEnd("|")
                    }

#Retrieve DataStore Cluster for each host datastore verify variable contains objects and concatenate results into DSCluster variable

            $DSCluster = ($vmhost | get-datastore | Get-DatastoreCluster)

                if ($DSCluster.count -gt '0')

                    {
                    $DSClusterString = ($DSCluster[0].name + "|" + $DSCluster[1].name + "|" + $DSCluster[2].name + "|" + $DSCluster[3].name).TrimEnd("|")
                    }

#Retrieve DataStore SIOC Settings for each host datastore 

           

                if ($HostDataStores.count -gt '0')

                    {

                    $Ds1SIOCEnabled      = $HostDataStores[0].ExtensionData.IormConfiguration.Enabled
                    $Ds2SIOCEnabled      = $HostDataStores[1].ExtensionData.IormConfiguration.Enabled
                    $Ds3SIOCEnabled      = $HostDataStores[2].ExtensionData.IormConfiguration.Enabled
                    $Ds4SIOCEnabled      = $HostDataStores[3].ExtensionData.IormConfiguration.Enabled

                    $Ds1StatsCollected   = $HostDataStores[0].ExtensionData.IormConfiguration.StatsCollectionEnabled
                    $Ds2StatsCollected   = $HostDataStores[1].ExtensionData.IormConfiguration.StatsCollectionEnabled
                    $Ds3StatsCollected   = $HostDataStores[2].ExtensionData.IormConfiguration.StatsCollectionEnabled
                    $Ds4StatsCollected   = $HostDataStores[3].ExtensionData.IormConfiguration.StatsCollectionEnabled

                    } 



                 
#Retrieve luns for current host and verify variable contains objects and expand results into several variables for up to two luns

            $luns = Get-ScsiLun -VmHost $vmhost | where {$_.Vendor -eq "PURE"}

                if ($luns.count -gt '0')

                    {
                    $lun1 = $luns[0]
                    $lun2 = $luns[1]
                    }

#Retrieve Online HBAs for current host and verify variable contains objects and expand results into several variables for up to two HBAs

            $HBAs = Get-VMHostHba -VMHost $vmhost |where {$_.status -eq 'online'}

                if ($HBAs.count -gt '0')

                    {
                    $hba1 = $hbas[0]
                    $hba2 = $hbas[1]
                    }

#Retrieve Default TCP stack for current host and verify variable contains objects and expand results into several variables for DNS

            $DefaultStack    = Get-VMHostNetworkStack -VMHost $vmhost |where {$_.name -eq 'defaultTcpipStack'}
                
                if ($DefaultStack.DnsAddress.Count -gt '0')

                    {
                    $DnsServerString = ($DefaultStack.DnsAddress[0] + '|' + $DefaultStack.DnsAddress[1] + '|' + $DefaultStack.DnsAddress[2] + '|' + $DefaultStack.DnsAddress[3]).TrimEnd("|")
                    $DnsString       = ($DefaultStack.DnsSearchDomain[0] + "|" + $DefaultStack.DnsSearchDomain[1] + $DefaultStack.DnsSearchDomain[2]).TrimEnd("|")
                    }

#Retrieve vMotion TCP stack for current host and store it in the vMotionStack variable

            $vmotionStack    = Get-VMHostNetworkStack -VMHost $vmhost |where {$_.name -eq 'vmotion'}

#Retrieve authentication settings for current host and store in the authentication variable
#Verify Authentication variable has objects inside and expand and concatenate into the AuthString variable

            $Authentication  = Get-VMHostAuthentication -VMHost $vmhost
            $TrustedDomains  = $Authentication.TrustedDomains

                if ($TrustedDomains.count -gt '0')

                    {
                    $DomainString = ($TrustedDomains[0] + '|' + $TrustedDomains[1] + '|' + $TrustedDomains[2] + '|' + $TrustedDomains[3]).TrimEnd("|")
                    }

#Retrieve local admin group settings for current host and store in the AdminGroups variable

            $AdminGroups     = (get-advancedsetting -entity $vmhost -name 'Config.HostAgent.plugins.hostsvc.esxAdminsGroup').Value


#Retrieve nic card settings for current host and store in the ncis variable
#Verify nics variable has objects inside and expand and concatenate into the several variables


            $nics            = (Get-vmhost -Name $vmhost | Get-VMHostNetworkAdapter | where{$_.name -like 'vmnic*'})

                if ($nics.count -gt '0')

                    {

                    $VMnic0String = $nics[0].DeviceName + "|" + $nics[0].BitRatePerSec + "|" + $nics[0].FullDuplex
                    $VMnic1String = $nics[1].DeviceName + "|" + $nics[1].BitRatePerSec + "|" + $nics[1].FullDuplex
                    $VMnic2String = $nics[2].DeviceName + "|" + $nics[2].BitRatePerSec + "|" + $nics[2].FullDuplex
                    $VMnic3String = $nics[3].DeviceName + "|" + $nics[3].BitRatePerSec + "|" + $nics[3].FullDuplex
                    $VMnic4String = $nics[4].DeviceName + "|" + $nics[4].BitRatePerSec + "|" + $nics[4].FullDuplex
                    $VMnic5String = $nics[5].DeviceName + "|" + $nics[5].BitRatePerSec + "|" + $nics[5].FullDuplex

                    }


#Retrieve VMhost Network Failback Delay Timer

            $FailBackdelay   = Get-AdvancedSetting -Name Net.TeamPolicyUpDelay -entity $vmhost
          
#Zero out or null obj variable

                $obj = $null

#Create PowerShell Custom object to combine retrieved fields for the current host
            
                $obj = [PsCustomobject] @{

                Host              = $vmhost.name
                DataStores        = $DataStoreString
                DSClusters        = $DSClusterString
                DS1SIOCEnabled    = $Ds1SIOCEnabled
                DS2SIOCEnabled    = $Ds2SIOCEnabled
                DS3SIOCEnabled    = $Ds3SIOCEnabled
                DS4SIOCEnabled    = $Ds4SIOCEnabled
                DS1StatsCollected = $Ds1StatsCollected
                DS2StatsCollected = $Ds2StatsCollected
                DS3StatsCollected = $Ds3StatsCollected
                DS4StatsCollected = $Ds4StatsCollected
                Lun1Vendor        = $lun1.Vendor
                Lun1Policy        = $lun1.MultipathPolicy
                Lun1Depth         = $lun1.ExtensionData.QueueDepth
                Lun2Vendor        = $lun2.Vendor
                Lun2Policy        = $lun2.MultipathPolicy
                Lun2Depth         = $lun2.ExtensionData.QueueDepth
                FCA               = $hba1.device
                FCAModel          = $hba1.Model
                FCADriver         = $hba1.Driver
                FCAStatus         = $hba1.status
                FCASpeed          = $hba1.speed
                FCB               = $hba2.device
                FCBModel          = $hba2.Model
                FCBDriver         = $hba2.Driver
                FCBStatus         = $hba2.status
                FCBSpeed          = $hba2.speed
                SyslogServer      = $syslogserver.host
                SyslogPort        = $syslogserver.port
                NTPRunning        = $ntpRunning
                NTPStartType      = $ntpStartType
                NTPServers        = $ntpString
                SnmpReceiver      = $SnmpReceiver
                SnmpStrings       = $SNMPStrings
                SnmpPort          = $SnmpPort
                Domain            = $Authentication.Domain
                TrustedDomain     = $DomainString
                ADStatus          = $Authentication.DomainMembershipStatus
                AdminGroups       = $AdminGroups
                DnsServers        = $DnsServerString
                DnsDomains        = $DnsString
                VMK0IP            = $vmk0.IP
                VMK0Subnet        = $vmk0.SubnetMask
                VMK0Gateway       = $DefaultStack.Gateway
                VMK0MTU           = $vmk0.Mtu
                VMK0PortGroup     = $vmk0.portgroupname
                VMK0MgmtEnable    = $vmk0.ManagementTrafficEnabled
                VMK0VmotionEnable = $vmk0.VMotionEnabled
                VMK1IP            = $vmk1.IP
                VMK1Subnet        = $vmk1.SubnetMask
                VMotionGateway    = $vmotionStack.Gateway
                VMK1MTU           = $vmk1.Mtu
                VMK1PortGroup     = $vmk1.portgroupname
                VMK1MgmtEnable    = $vmk1.ManagementTrafficEnabled
                VMK1VmotionEnable = $vmk1.VMotionEnabled
                VMK2IP            = $vmk2.IP
                VMK2Subnet        = $vmk2.SubnetMask
                VMK2MTU           = $vmk2.Mtu
                VMK2PortGroup     = $vmk2.portgroupname
                VMK2MgmtEnable    = $vmk2.ManagementTrafficEnabled
                VMK2VmotionEnable = $vmk2.VMotionEnabled
		VMK3IP            = $vmk3.IP
                VMK3Subnet        = $vmk3.SubnetMask
                VMK3MTU           = $vmk3.Mtu
                VMK3PortGroup     = $vmk3.portgroupname
                VMK3MgmtEnable    = $vmk3.ManagementTrafficEnabled
                VMK3VmotionEnable = $vmk3.VMotionEnabled
                VMK4IP            = $vmk4.IP
                VMK4Subnet        = $vmk4.SubnetMask
                VMK4MTU           = $vmk4.Mtu
                VMK4PortGroup     = $vmk4.portgroupname
                VMK4MgmtEnable    = $vmk4.ManagementTrafficEnabled
                VMK4VmotionEnable = $vmk4.VMotionEnabled
                VDS0Name          = $vds0.Name
                VDS1Name          = $vds1.Name
                VMNIC0            = $VMnic0String
                VMNIC1            = $VMnic1String
                VMNIC4            = $VMnic4String
                VMNIC5            = $VMnic5String
                VMNIC2            = $VMnic2String
                VMNIC3            = $VMnic3String
                FailBackDelay     = $FailBackdelay.Value
 
               

                }

#Stack the current object stored in the obj variable into array called results

                 $results += $obj 

                }

#Export the collection of custom objects for each host into a csv file
#Exports results to PowerShell gridview

            $results | export-csv -NoTypeInformation $OutputFile
            $results | ogv

            
          