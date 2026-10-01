<#
.SYNOPSIS
    Seeds a Windows DNS server with a reverse zone, forwarder and lab A/PTR records.
.DESCRIPTION
    Creates a reverse lookup zone, adds a forwarder, and registers forward A records
    (with matching PTRs) for a vSphere lab (vCenter, ESXi hosts, NSX, vRNI). Run on the
    lab domain controller / DNS server. Adjust the subnet, zone and host records to suit.
.NOTES
    Author : Steven Slocum
    Notes  : Portfolio copy of a real-world script. Lab values (lab.local, RFC1918)
             and placeholder secrets substituted for any originals.
#>

#Install Reverse DNS Zone

Add-DNSServerPrimaryZone -NetworkID 192.168.60.0/24 -ReplicationScope Forest

#Add DNS forwarder

Add-DnsServerforwarder -IPAddress 192.168.60.9

#Create SITE-A DNS A / PTR Records

Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-vcentera -IPv4Address 192.168.60.20 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-esxia-1 -IPv4Address 192.168.60.21 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-esxia-2 -IPv4Address 192.168.60.22 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-esxia-3 -IPv4Address 192.168.60.23 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-esxia-4 -IPv4Address 192.168.60.24 -CreatePtr

Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-nsxa -IPv4Address 192.168.60.30 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-nsxa-1 -IPv4Address 192.168.60.31 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-nsxa-2 -IPv4Address 192.168.60.32 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-nsxa-3 -IPv4Address 192.168.60.33 -CreatePtr

Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-vrnia -IPv4Address 192.168.60.40 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-vrnia-proxy1 -IPv4Address 192.168.60.41 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-vrnia-proxy2 -IPv4Address 192.168.60.42 -CreatePtr


Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-vcentera -IPv4Address 192.168.60.20 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-esxia-1 -IPv4Address 192.168.60.21 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-esxia-2 -IPv4Address 192.168.60.22 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-esxia-3 -IPv4Address 192.168.60.23 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-esxia-4 -IPv4Address 192.168.60.24 -CreatePtr

Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-nsxa -IPv4Address 192.168.60.30 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-nsxa-1 -IPv4Address 192.168.60.31 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-nsxa-2 -IPv4Address 192.168.60.32 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-nsxa-3 -IPv4Address 192.168.60.33 -CreatePtr

Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-vrnia -IPv4Address 192.168.60.40 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-vrnia-proxy1 -IPv4Address 192.168.60.41 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-vrnia-proxy2 -IPv4Address 192.168.60.42 -CreatePtr

#Create SITE-B DNS A / PTR Records

Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-vcentera -IPv4Address 192.168.60.20 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-esxia-1 -IPv4Address 192.168.60.21 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-esxia-2 -IPv4Address 192.168.60.22 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-esxia-3 -IPv4Address 192.168.60.23 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-esxia-4 -IPv4Address 192.168.60.24 -CreatePtr

Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-nsxa -IPv4Address 192.168.60.30 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-nsxa-1 -IPv4Address 192.168.60.31 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-nsxa-2 -IPv4Address 192.168.60.32 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-nsxa-3 -IPv4Address 192.168.60.33 -CreatePtr

Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-vrnia -IPv4Address 192.168.60.40 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-vrnia-proxy1 -IPv4Address 192.168.60.41 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-vrnia-proxy2 -IPv4Address 192.168.60.42 -CreatePtr


Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-vcenterb -IPv4Address 192.168.60.120 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-esxib-1 -IPv4Address 192.168.60.121 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-esxib-2 -IPv4Address 192.168.60.122 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-esxib-3 -IPv4Address 192.168.60.123 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-esxib-4 -IPv4Address 192.168.60.124 -CreatePtr

Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-nsxb -IPv4Address 192.168.60.130 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-nsxb-1 -IPv4Address 192.168.60.131 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-nsxb-2 -IPv4Address 192.168.60.132 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-nsxb-3 -IPv4Address 192.168.60.133 -CreatePtr

Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-vrnib -IPv4Address 192.168.60.140 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-vrnib-proxy1 -IPv4Address 192.168.60.141 -CreatePtr
Add-DNSServerResourceRecordA -ZoneName lab.local -Name k1-vrnib-proxy2 -IPv4Address 192.168.60.142 -CreatePtr



