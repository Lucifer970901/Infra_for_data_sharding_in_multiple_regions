resource "oci_core_vcn" "test_vcn_anz" {
    #Required
    provider       = oci.region2
    cidr_block = var.vcn_cidr_block
    compartment_id = var.compartment_ocid
    display_name = var.display_name_vcn
    dns_label = var.vcn_dns_label
}

#resource block for defining public subnet
resource "oci_core_subnet" "publicsubnet_anz"{
provider       = oci.region2
dns_label = "PublicSubnet"
compartment_id = var.compartment_ocid
vcn_id = oci_core_vcn.test_vcn_anz.id
display_name = var.display_name_publicsubnet
cidr_block = var.cidr_block_publicsubnet
route_table_id = oci_core_route_table.publicRT_anz.id
security_list_ids = [oci_core_security_list.publicSL_anz.id]
}

resource "oci_core_subnet" "privatesubnet_anz"{
provider       = oci.region2
dns_label = "PrivateSubnet"
compartment_id = var.compartment_ocid
vcn_id = oci_core_vcn.test_vcn_anz.id
display_name = var.display_name_privatesubnet
cidr_block = var.cidr_block_privatesubnet
prohibit_public_ip_on_vnic = "true"
route_table_id = oci_core_route_table.privateRT_anz.id
security_list_ids = [oci_core_security_list.privateSL_anz_anz.id]
}

#resource block for internet gateway
resource "oci_core_internet_gateway" "test_internet_gateway_anz" {
  provider       = oci.region2
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.test_vcn_anz.id
}

resource "oci_core_nat_gateway" "test_nat_gateway_anz" {
    #Required
    provider       = oci.region2
    compartment_id =var.compartment_ocid
    vcn_id = oci_core_vcn.test_vcn_anz.id
}

resource "oci_core_drg" "test_drg_anz" {
    #Required
    provider       = oci.region2
    compartment_id = var.compartment_ocid
}

resource "oci_core_drg_attachment" "test_drg_vcn_attachment_anz" {
    #Required
    provider       = oci.region2
    drg_id = oci_core_drg.test_drg_anz.id
    network_details {
        #Required
        id = oci_core_vcn.test_vcn_anz.id
        type = "VCN"
        route_table_id = oci_core_route_table.privateRT_anz.id
    }
}
resource "oci_core_remote_peering_connection" "test_remote_peering_connection_anz" {
    #Required
    provider       = oci.region2
    compartment_id = var.compartment_id
    drg_id = oci_core_drg.test_drg_anz.id

    #Optional
    peer_id = oci_core_remote_peering_connection.test_remote_peering_connection2.id
    peer_region_name = var.remote_peering_connection_peer_region_name
}

resource "oci_core_drg_attachment" "test_drg_rpc_attachment_anz" {
    #Required
    provider       = oci.region2
    drg_id = oci_core_drg.test_drg_anz.id
    network_details {
        #Required
        id = oci_core_vcn.test_vcn_anz.id
        type = "VCN"
        route_table_id = oci_core_route_table.privateRT_anz.id
    }
}

#resource block for route table with route rule for internet gateway
resource "oci_core_route_table" "publicRT_anz" {
provider       = oci.region2
vcn_id = oci_core_vcn.test_vcn_anz.id
compartment_id = var.compartment_ocid
display_name = "public_route_table"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.test_internet_gateway_anz.id
  }
}
# #resource block for private route table 
resource "oci_core_route_table" "privateRT_anz"{
provider       = oci.region2
compartment_id = var.compartment_ocid
vcn_id = oci_core_vcn.test_vcn_anz.id
display_name = "private_route_table"
route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.test_nat_gateway_anz.id
  }
#route_rules {
 #   destination       = "0.0.0.0/0"
  #  network_entity_id = oci_core_service_gateway.test_service_gateway_anz.id
  #}
}


#resource block for public security list
resource "oci_core_security_list" "publicSL_anz" {
  provider       = oci.region2
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.test_vcn_anz.id
  display_name   = "public_security_list"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
  ingress_security_rules {
    tcp_options {
      max = "22"
      min = "22"
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  }
 ingress_security_rules {
    icmp_options {
      type = "3"
    }

    protocol = "1"
    source   = "192.168.0.0/16"
  }
  ingress_security_rules {
    icmp_options {
      type = "3"
      code = "4"
    }

    protocol = "1"
    source   = "0.0.0.0/0"
  }
}
resource "oci_core_security_list" "privateSL_anz" {
  provider       = oci.region2
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.test_vcn_anz.id
  display_name   = "private_security_list"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
  ingress_security_rules {
    tcp_options {
      max = "22"
      min = "22"
    }

    protocol = "6"
    source   = "192.168.0.0/16"
  }
  
  ingress_security_rules {
    tcp_options {
      max = "1521"
      min = "1521"
    }

    protocol = "6"
    source   = "192.168.0.0/16"
    }
    
  ingress_security_rules {
    icmp_options {
      type = "3"
    }

    protocol = "1"
    source   = "192.168.0.0/16"
  }
  ingress_security_rules {
    icmp_options {
      type = "3"
      code = "4"
    }

    protocol = "1"
    source   = "0.0.0.0/0"
  }
  
}
