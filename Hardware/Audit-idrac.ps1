<#
.SYNOPSIS
    Audits Dell iDRAC/Redfish inventory for a list of iDRAC endpoints.
.DESCRIPTION
    Reads a file of iDRAC addresses and queries each over the Redfish REST API
    (TLS validation bypassed for self-signed iDRAC certs) to collect hardware
    inventory, writing results to an output file.
.PARAMETER idracfile
    Text file with one iDRAC host/IP per line.
.PARAMETER outputfile
    Destination report path.
.PARAMETER idracuser
    iDRAC username.
.PARAMETER idracpassword
    iDRAC password as a SecureString.
.NOTES
    Author : Steven Slocum
    Notes  : Portfolio copy of a real-world script. Lab values (lab.local, RFC1918)
             and placeholder secrets substituted for any originals.
#>

[cmdletbinding()]

param(

[parameter(Mandatory = $true)]
[string]$idracfile,

[parameter(Mandatory = $true)]
[string]$outputfile,

[parameter(Mandatory = $true)]
[string]$idracuser,

[parameter(Mandatory = $true)]
[securestring]$idracpassword

)

function Ignore-SSLCertificates
{
    $Provider = New-Object Microsoft.CSharp.CSharpCodeProvider
    $Compiler = $Provider.CreateCompiler()
    $Params = New-Object System.CodeDom.Compiler.CompilerParameters
    $Params.GenerateExecutable = $false
    $Params.GenerateInMemory = $true
    $Params.IncludeDebugInformation = $false
    $Params.ReferencedAssemblies.Add("System.DLL") > $null
    $TASource=@'
        namespace Local.ToolkitExtensions.Net.CertificatePolicy
        {
            public class TrustAll : System.Net.ICertificatePolicy
            {
                public bool CheckValidationResult(System.Net.ServicePoint sp,System.Security.Cryptography.X509Certificates.X509Certificate cert, System.Net.WebRequest req, int problem)
                {
                    return true;
                }
            }
        }
'@ 
    $TAResults=$Provider.CompileAssemblyFromSource($Params,$TASource)
    $TAAssembly=$TAResults.CompiledAssembly
    ## We create an instance of TrustAll and attach it to the ServicePointManager
    $TrustAll = $TAAssembly.CreateInstance("Local.ToolkitExtensions.Net.CertificatePolicy.TrustAll")
    [System.Net.ServicePointManager]::CertificatePolicy = $TrustAll
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12

$idrachosts     = (Get-Content $idracfile)

$results        = @()


$credential     = New-Object System.Management.Automation.PSCredential($idracuser, $idracpassword)




foreach ($i in $idrachosts){

Ignore-SSLCertificates

               
                $Attributes         =                 $null
                $Hostname           =                 $null
                $BiosVersion        =                 $null
                $Firmware           =                 $null
                $IP1                 =                $null
                $Subnet             =                 $null
                $Gateway            =                 $null
                $DNS1               =                 $null
                $DNS2               =                 $null
                $Sel                =                 $null
                $SelCount           =                 $null            
                $Domain             =                 $null
                $NTP1               =                 $null
                $NTP2               =                 $null
                $NTP3               =                 $null
                $SNMP               =                 $null
                $Port               =                 $null
                $Syslog             =                 $null
                $ADGroup1           =                 $null
                $ADGroup2           =                 $null
                $ADGroup1Domain     =                 $null
                $ADGroup2Domain     =                 $null
                $System             =                 $null
                $PCI                =                 $null
                $adapater           =                 $null
                $HBAs               =                 $null
                $HBA1               =                 $null
                $HBA2               =                 $null

               
[string]$PCIeDevice     = @()
        $HBAs           = @()

        $Attributes = Invoke-RestMethod -Credential $credential -Method Get -UseBasicParsing -ErrorVariable RespErr -Headers @{"Accept"="application/json"} -uri "https://$i/redfish/v1/Managers/iDRAC.Embedded.1/Attributes/"

        $Sel        = Invoke-RestMethod -Credential $credential -Method Get -UseBasicParsing -ErrorVariable RespErr -Headers @{"Accept"="application/json"} -uri "https://$i/redfish/v1/Managers/iDRAC.Embedded.1/LogServices/Sel/Entries"

        $system     = Invoke-RestMethod -Credential $credential -Method Get -UseBasicParsing -ErrorVariable RespErr -Headers @{"Accept"="application/json"} -uri "https://$i/redfish/v1/Systems/System.Embedded.1"

        $PCI        = $system.PCIeDevices

            foreach ($p in $pci)
                {
                
                $PCIeDevice    = $p
                $PCIeDevice    = $PCIeDevice.Remove(0, 12).Trimend("}").Insert(0, "https://$i")
                $adapater      = Invoke-RestMethod -Credential $credential -Method Get -UseBasicParsing -ErrorVariable RespErr -Headers @{"Accept"="application/json"} -uri $PCIeDevice

                $HBAS += $adapater


                }

                $HBAs = $HBAs | where {$_.Manufacturer -eq 'Emulex Corporation'}



                $HostName           =                 ($attributes).Attributes.'NIC.1.DNSRacName'
                $BiosVersion        =                 $System.BiosVersion
                $HBA1               =                 $HBAs[0].Description.Trim(" Fibre Channel Adapter")
                $HBA1BusID          =                 $HBAs[0].ID
                $HBA1Firmware       =                 $HBAs[0].FirmwareVersion
                $HBA2               =                 $HBAs[1].Description.Trim(" Fibre Channel Adapter")
                $HBA2BusID          =                 $HBAs[1].ID
                $HBA2Firmware       =                 $HBAs[1].FirmwareVersion
                $Firmware           =                 ($attributes).Attributes.'Info.1.Version'
                $IP1                =                 ($attributes).Attributes.'IPv4.1.Address'
                $Subnet             =                 ($attributes).Attributes.'IPv4.1.Netmask'
                $Gateway            =                 ($attributes).Attributes.'IPv4.1.Gateway'
                $DNS1               =                 ($attributes).Attributes.'IPv4.1.DNS1'
                $DNS2               =                 ($attributes).Attributes.'IPv4.1.DNS2'
                $SelCount           =                 ($sel).'Members@odata.count'
                $Domain             =                 ($attributes).Attributes.'NIC.1.DNSDomainName'
                $NTP1               =                 ($attributes).Attributes.'NTPConfigGroup.1.NTP1'
                $NTP2               =                 ($attributes).Attributes.'NTPConfigGroup.1.NTP2'
                $NTP3               =                 ($attributes).Attributes.'NTPConfigGroup.1.NTP3'
                $SNMP               =                 ($attributes).Attributes.'SNMPAlert.1.Destination'
                $Port               =                 ($attributes).Attributes.'NIC.1.SwitchPortConnection'
                $Syslog             =                 ($attributes).Attributes.'SysLog.1.Server1'
                $ADGroup1           =                 ($attributes).Attributes.'ADGroup.1.Name'
                $ADGroup1Domain     =                 ($attributes).Attributes.'ADGroup.1.Domain'
                $ADGroup2           =                 ($attributes).Attributes.'ADGroup.2.Name'
                $ADGroup2Domain     =                 ($attributes).Attributes.'ADGroup.1.Domain'
                $Community          =                 ($attributes).Attributes.'IPMILan.1.CommunityName'

                $obj = [PsCustomobject] @{


                HostName            =                 $HostName
                BiosVersion         =                 $BiosVersion
                Firmware            =                 $Firmware
                IP1                 =                 $IP1
                Subnet              =                 $Subnet
                Gateway             =                 $Gateway
                DNS1                =                 $DNS1
                DNS2                =                 $DNS2
                SelLogCount         =                 $SelCount
                Domain              =                 $Domain
                NTP1                =                 $NTP1
                NTP2                =                 $NTP2
                NTP3                =                 $NTP3
                SNMP                =                 $SNMP
                Port                =                 $Port
                Syslog              =                 $Syslog
                ADGroup1            =                 $ADGroup1
                ADGroup2            =                 $ADGroup2
                ADGroup1Domain      =                 $ADGroup1Domain 
                ADGroup2Domain      =                 $ADGroup2Domain 
                Community           =                 $Community
                HBA1                =                 $HBA1
                HBA1BusID           =                 $HBA1BusID
                HBA1Firmware        =                 $HBA1Firmware
                HBA2                =                 $HBA2
                HBA2BusID           =                 $HBA2BusID
                HBA2Firmware        =                 $HBA2Firmware
                



                }


                $results += $obj 


}


                $results | export-csv -NoTypeInformation $OutputFile
                $results | ogv





