<#
.SYNOPSIS
    Stands up a lab datacenter/cluster and deploys nested ESXi appliances.
.DESCRIPTION
    Connects to vCenter, creates a datacenter and HA/DRS/vSAN cluster, then deploys
    nested-ESXi appliances from an OVA and joins them to the cluster. Credentials and
    host passwords are read from environment variables (VC_PASSWORD / ESXI_PASSWORD).
.NOTES
    Author : Steven Slocum
    Notes  : Portfolio copy of a real-world PowerCLI script. Lab values (lab.local,
             RFC1918) and placeholder secrets substituted for any originals.
    Edit the inline $vcname/$ovffile/$datastore variables for your environment.
#>

#Deploy ESXI Appliances#

$vcname                  = "vcenter67.lab.local"
$vcuser                  = "administrator@vsphere.local"
$vcpass                  = $env:VC_PASSWORD

$ovffile                 = "C:\dev\Nested_ESXi6.7u2_Appliance_Template_v1.ova"
 
$cluster                 = "Cluster-A"
$vmnetwork               = "VM Network"
$datastore               = "ESXI2-DAS2"
$dns                     = "192.168.109.100"
$dnsdomain               = "lab.local"
$ntp                     = "192.168.109.100"
$syslog                  = "192.168.109.100"
$password                = $env:ESXI_PASSWORD
$ssh                     = "True"


$vcenter = Connect-VIServer $vcname -User $vcuser -Password $vcpass -WarningAction SilentlyContinue

#Create DataCenter
New-Datacenter -Location datacenters -Name Site-A
New-Cluster -Name Cluster-A -Location Site-A -HAEnabled -DrsEnabled -DrsAutomationLevel FullyAutomated -VsanEnabled -VsanDiskClaimMode Automatic

$datastore_ref           = Get-Datastore -Name $datastore
$network_ref             = Get-VirtualPortGroup -Name $vmnetwork
$cluster_ref             = Get-Cluster -Name $cluster
$vmhost_ref              = $cluster_ref | Get-VMHost | Select -First 1


    #Set config parameters for first host
    $ovfconfig                                             = Get-OvfConfiguration $ovffile

    $ovfconfig.common.guestinfo.hostname.value             = "ESXI-1"
    $ovfconfig.common.guestinfo.ipaddress.value            = "192.168.109.90"
    $ovfconfig.common.guestinfo.netmask.value              = "255.255.255.0"
    $ovfconfig.common.guestinfo.gateway.value              = "192.168.109.2"

    $ovfconfig.NetworkMapping.VM_Network.value             = $network_ref
    $ovfconfig.common.guestinfo.dns.value                  = $dns
    $ovfconfig.common.guestinfo.domain.value               = $dnsdomain
    $ovfconfig.common.guestinfo.ntp.value                  = $ntp
    $ovfconfig.common.guestinfo.syslog.value               = $syslog
    $ovfconfig.common.guestinfo.password.value             = $password
    $ovfconfig.common.guestinfo.ssh.value                  = $ssh

    # Deploy the first OVF/OVA with the config parameters
    Write-Host "Deploying ESXI-1 ..."
    $vm = Import-VApp -Source $ovffile -OvfConfiguration $ovfconfig -Name ESXI-1 -Location $cluster_ref -VMHost 192.168.109.104 -Datastore $datastore_ref -DiskStorageFormat thin
    $vm | Start-Vm -RunAsync | Out-Null


    #Reset Config parameters for second host

    $ovfconfig                                             = Get-OvfConfiguration $ovffile

    $ovfconfig.common.guestinfo.hostname.value             = "ESXI-2"
    $ovfconfig.common.guestinfo.ipaddress.value            = "192.168.109.91"
    $ovfconfig.common.guestinfo.netmask.value              = "255.255.255.0"
    $ovfconfig.common.guestinfo.gateway.value              = "192.168.109.2"

    $ovfconfig.NetworkMapping.VM_Network.value             = $network_ref
    $ovfconfig.common.guestinfo.dns.value                  = $dns
    $ovfconfig.common.guestinfo.domain.value               = $dnsdomain
    $ovfconfig.common.guestinfo.ntp.value                  = $ntp
    $ovfconfig.common.guestinfo.syslog.value               = $syslog
    $ovfconfig.common.guestinfo.password.value             = $password
    $ovfconfig.common.guestinfo.ssh.value                  = $ssh


    # Deploy the second OVF/OVA with the config parameters
    Write-Host "Deploying ESXI-2 ..."
    $vm = Import-VApp -Source $ovffile -OvfConfiguration $ovfconfig -Name ESXI-2 -Location $cluster_ref -VMHost 192.168.109.104 -Datastore $datastore_ref -DiskStorageFormat thin
    $vm | Start-Vm -RunAsync | Out-Null

    #Reset Config parameters for third host
    $ovfconfig                                             = Get-OvfConfiguration $ovffile

    $ovfconfig.common.guestinfo.hostname.value             = "ESXI-3"
    $ovfconfig.common.guestinfo.ipaddress.value            = "192.168.109.92"
    $ovfconfig.common.guestinfo.netmask.value              = "255.255.255.0"
    $ovfconfig.common.guestinfo.gateway.value              = "192.168.109.2"

    $ovfconfig.NetworkMapping.VM_Network.value             = $network_ref
    $ovfconfig.common.guestinfo.dns.value                  = $dns
    $ovfconfig.common.guestinfo.domain.value               = $dnsdomain
    $ovfconfig.common.guestinfo.ntp.value                  = $ntp
    $ovfconfig.common.guestinfo.syslog.value               = $syslog
    $ovfconfig.common.guestinfo.password.value             = $password
    $ovfconfig.common.guestinfo.ssh.value                  = $ssh


    # Deploy the third OVF/OVA with the config parameters
    Write-Host "Deploying ESXI-3 ..."
    $vm = Import-VApp -Source $ovffile -OvfConfiguration $ovfconfig -Name ESXI-3 -Location $cluster_ref -VMHost 192.168.109.104 -Datastore $datastore_ref -DiskStorageFormat thin
    $vm | Start-Vm -RunAsync | Out-Null

    #Wait for ESXI hosts to boot
    Write-Host "Waiting 12 minutes for hosts to boot"
    Start-Sleep -Seconds 720

    #Join Hosts to vCenter
    Write-Host "Join Hosts to vCenter"
    Add-vmhost -Name esxi-1.lab.local -Location Cluster-A -User root -Password $env:ESXI_PASSWORD -Force
    Add-vmhost -Name esxi-2.lab.local -Location Cluster-A -User root -Password $env:ESXI_PASSWORD -Force
    Add-vmhost -Name esxi-3.lab.local -Location Cluster-A -User root -Password $env:ESXI_PASSWORD -Force

    #Disable IPv6 for hosts
    write-host "Disable IPv6 for hosts"
    $esxcli = Get-EsxCli -VMHost (Get-VMHost "esxi-1.lab.local") -V2
    $esxcli.network.ip.set.Invoke(@{ipv6enabled='false'})

    $esxcli = Get-EsxCli -VMHost (Get-VMHost "esxi-2.lab.local") -V2
    $esxcli.network.ip.set.Invoke(@{ipv6enabled='false'})

    $esxcli = Get-EsxCli -VMHost (Get-VMHost "esxi-3.lab.local") -V2
    $esxcli.network.ip.set.Invoke(@{ipv6enabled='false'})

    #Disable vSAN for vmk0
    write-host "Disable vSAN for vmk0"
    get-vmhost -Name esxi-1.lab.local |Get-VMHostNetworkAdapter -VMKernel -Name vmk0 |Set-VMHostNetworkAdapter -Mtu 9000 -VsanTrafficEnabled $false -Confirm:$false
    get-vmhost -Name esxi-2.lab.local |Get-VMHostNetworkAdapter -VMKernel -Name vmk0 |Set-VMHostNetworkAdapter -Mtu 9000 -VsanTrafficEnabled $false -Confirm:$false
    get-vmhost -Name esxi-3.lab.local |Get-VMHostNetworkAdapter -VMKernel -Name vmk0 |Set-VMHostNetworkAdapter -Mtu 9000 -VsanTrafficEnabled $false -Confirm:$false

    #Add VM/Host VMNIC/Phsysical Adapaters
    write-host "Add VM/Host VMNIC/Phsysical Adapaters"
    New-NetworkAdapter -VM ESXI-1 -Type Vmxnet3 -NetworkName "VM Network" -StartConnected
    New-NetworkAdapter -VM ESXI-1 -Type Vmxnet3 -NetworkName "VM Network" -StartConnected

    New-NetworkAdapter -VM ESXI-2 -Type Vmxnet3 -NetworkName "VM Network" -StartConnected
    New-NetworkAdapter -VM ESXI-2 -Type Vmxnet3 -NetworkName "VM Network" -StartConnected
   
    New-NetworkAdapter -VM ESXI-3 -Type Vmxnet3 -NetworkName "VM Network" -StartConnected
    New-NetworkAdapter -VM ESXI-3 -Type Vmxnet3 -NetworkName "VM Network" -StartConnected

    #Reboot ESXI to detect new Network adapters
    write-host "Reboot ESXI to detect new Network adapters"
    Restart-VMHost -VMHost esxi-1.lab.local -Force -Confirm:$false
    Restart-VMHost -VMHost esxi-2.lab.local -Force -Confirm:$false
    Restart-VMHost -VMHost esxi-3.lab.local -Force -Confirm:$false

    #Wait for ESXI hosts to boot
    write-host "Wait 12 minutes for ESXI hosts to boot - second reboot"
    Start-Sleep -Seconds 720


    #Create vSAN-vMotion and VXLAN VDS and port groups
    Write-Host "Create vSAN-vMotion and VXLAN VDS and port groups"
    New-VDSwitch -LinkDiscoveryProtocol CDP -LinkDiscoveryProtocolOperation Both -Mtu 9000 -NumUplinkPorts 2 -Name Site-A-VDS-VXLAN -Location Site-A
    New-VDSwitch -LinkDiscoveryProtocol CDP -LinkDiscoveryProtocolOperation Both -Mtu 9000 -NumUplinkPorts 2 -Name Site-A-VDS-vSAN-vMotion -Location Site-A
    New-VDPortgroup -VDSwitch Site-A-VDS-vSAN-vMotion -Name Site-A-DvPG-vSAN-vMotion

    #Add VMhosts to VDS
    Write-Host "Add VMhosts to Site-A-VDS-VXLAN"
    Add-VDSwitchVMHost -VDSwitch Site-A-VDS-VXLAN -VMHost esxi-1.lab.local
    Add-VDSwitchVMHost -VDSwitch Site-A-VDS-VXLAN -VMHost esxi-2.lab.local
    Add-VDSwitchVMHost -VDSwitch Site-A-VDS-VXLAN -VMHost esxi-3.lab.local

    Write-Host "Add VMhosts to Site-A-VDS-vSAN-vMotion"
    Add-VDSwitchVMHost -VDSwitch Site-A-VDS-vSAN-vMotion -VMHost esxi-1.lab.local
    Add-VDSwitchVMHost -VDSwitch Site-A-VDS-vSAN-vMotion -VMHost esxi-2.lab.local
    Add-VDSwitchVMHost -VDSwitch Site-A-VDS-vSAN-vMotion -VMHost esxi-3.lab.local

    #Retrive VMhost VMnics as PowerCLI Objects
    Write-Host "Retrive VMhost VMnics as PowerCLI Objects"
    $host1nic1   = Get-VMHostNetworkAdapter -VMHost esxi-1.lab.local -Physical -Name vmnic1
    $host1nic2   = Get-VMHostNetworkAdapter -VMHost esxi-2.lab.local -Physical -Name vmnic2
    $host1nic3   = Get-VMHostNetworkAdapter -VMHost esxi-3.lab.local -Physical -Name vmnic3

    $host2nic1   = Get-VMHostNetworkAdapter -VMHost esxi-1.lab.local -Physical -Name vmnic1
    $host2nic2   = Get-VMHostNetworkAdapter -VMHost esxi-2.lab.local -Physical -Name vmnic2
    $host2nic3   = Get-VMHostNetworkAdapter -VMHost esxi-3.lab.local -Physical -Name vmnic3

    $host3nic1   = Get-VMHostNetworkAdapter -VMHost esxi-1.lab.local -Physical -Name vmnic1
    $host3nic2   = Get-VMHostNetworkAdapter -VMHost esxi-2.lab.local -Physical -Name vmnic2
    $host3nic3   = Get-VMHostNetworkAdapter -VMHost esxi-3.lab.local -Physical -Name vmnic3

    #Assign VMhost NICs to VDS
    Write-Host "Assign VMhost NICs to VDS"
    Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $host1nic1 -DistributedSwitch Site-A-VDS-vSAN-vMotion -Confirm:$false
    Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $host1nic2 -DistributedSwitch Site-A-VDS-VXLAN -Confirm:$false
    Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $host1nic3 -DistributedSwitch Site-A-VDS-VXLAN -Confirm:$false

    Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $host2nic1 -DistributedSwitch Site-A-VDS-vSAN-vMotion -Confirm:$false
    Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $host2nic2 -DistributedSwitch Site-A-VDS-VXLAN -Confirm:$false
    Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $host2nic3 -DistributedSwitch Site-A-VDS-VXLAN -Confirm:$false

    Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $host3nic1 -DistributedSwitch Site-A-VDS-vSAN-vMotion -Confirm:$false
    Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $host3nic2 -DistributedSwitch Site-A-VDS-VXLAN -Confirm:$false
    Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $host3nic3 -DistributedSwitch Site-A-VDS-VXLAN -Confirm:$false

    #Create Host vSAN/vMotion Kernerl Interfaces
    Write-Host "Create Host vSAN/vMotion Kernerl Interfaces"
    New-VMHostNetworkAdapter -VMHost esxi-1.lab.local -VirtualSwitch Site-A-VDS-vSAN-vMotion -PortGroup Site-A-DvPG-vSAN-vMotion -IP 10.10.10.10 -SubnetMask 255.255.255.0 -ManagementTrafficEnabled $false -VMotionEnabled $true -VsanTrafficEnabled $true
    New-VMHostNetworkAdapter -VMHost esxi-2.lab.local -VirtualSwitch Site-A-VDS-vSAN-vMotion -PortGroup Site-A-DvPG-vSAN-vMotion -IP 10.10.10.11 -SubnetMask 255.255.255.0 -ManagementTrafficEnabled $false -VMotionEnabled $true -VsanTrafficEnabled $true
    New-VMHostNetworkAdapter -VMHost esxi-3.lab.local -VirtualSwitch Site-A-VDS-vSAN-vMotion -PortGroup Site-A-DvPG-vSAN-vMotion -IP 10.10.10.12 -SubnetMask 255.255.255.0 -ManagementTrafficEnabled $false -VMotionEnabled $true -VsanTrafficEnabled $true











