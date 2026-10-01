output "vcn_id" {
  value = oci_core_vcn.sddc.id
}

output "provisioning_subnet_id" {
  value = oci_core_subnet.provisioning.id
}

output "vlan_ids" {
  description = "Map of segment key -> VLAN OCID (keys: vsphere, vmotion, vsan, nsx_vtep, nsx_edge_vtep, nsx_edge_uplink1, nsx_edge_uplink2, replication, hcx, provisioning_vlan)."
  value       = { for name, vlan in oci_core_vlan.sddc : name => vlan.id }
}

output "segment_cidrs" {
  value = local.segment_cidrs
}

output "route_table_ids" {
  value = merge(
    { for name, rt in oci_core_route_table.vlan : name => rt.id },
    { provisioning_subnet = oci_core_route_table.provisioning_subnet.id }
  )
}

output "nsg_ids" {
  value = merge(
    { for name, nsg in oci_core_network_security_group.vlan : name => nsg.id },
    var.enable_public_management ? { management = oci_core_network_security_group.management[0].id } : {}
  )
}

output "internet_gateway_id" {
  value = oci_core_internet_gateway.igw.id
}

output "nat_gateway_id" {
  value = oci_core_nat_gateway.nat.id
}
