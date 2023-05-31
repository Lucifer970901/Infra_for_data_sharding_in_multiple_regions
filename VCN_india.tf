resource "oci_core_vcn" "test_vcn_mumbai" {
    #Required
    provider       = oci.region1
    cidr_block = var.vcn_cidr_block
    compartment_id = var.compartment_ocid
    display_name = var.display_name_vcn
    dns_label = var.vcn_dns_label
}

#resource block for defining public subnet
resource "oci_core_subnet" "publicsubnet_mumbai"{
provider       = oci.region1
dns_label = "PublicSubnet"
compartment_id = var.compartment_ocid
vcn_id = oci_core_vcn.test_vcn_mumbai.id
display_name = var.display_name_publicsubnet
cidr_block = var.cidr_block_publicsubnet
route_table_id = oci_core_route_table.publicRT_mumbai.id
security_list_ids = [oci_core_security_list.publicSL_mumbai.id]
}

resource "oci_core_subnet" "privatesubnet_mumbai"{
provider       = oci.region1
dns_label = "PrivateSubnet"
compartment_id = var.compartment_ocid
vcn_id = oci_core_vcn.test_vcn_mumbai.id
display_name = var.display_name_privatesubnet
cidr_block = var.cidr_block_privatesubnet
prohibit_public_ip_on_vnic = "true"
route_table_id = oci_core_route_table.privateRT_mumbai.id
security_list_ids = [oci_core_security_list.privateSL_mumbai.id]
}

#resource block for internet gateway
resource "oci_core_internet_gateway" "test_internet_gateway_mumbai" {
  provider       = oci.region1
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.test_vcn_mumbai.id
}

resource "oci_core_nat_gateway" "test_nat_gateway_mumbai" {
    #Required
    provider       = oci.region1
    compartment_id =var.compartment_ocid
    vcn_id = oci_core_vcn.test_vcn_mumbai.id
}

resource "oci_core_drg" "test_drg" {
    #Required
    provider       = oci.region1
    compartment_id = var.compartment_ocid
}

resource "oci_core_drg_attachment" "test_drg_vcn_attachment_mumbai" {
    #Required
    provider       = oci.region1
    drg_id = oci_core_drg.test_drg_mumbai.id
    network_details {
        #Required
        id = oci_core_vcn.test_vcn_mumbai.id
        type = "VCN"
        route_table_id = oci_core_route_table.privateRT_mumbai.id
    }
}

resource "oci_core_drg_attachment" "test_drg_rpc_attachment_mumbai" {
    #Required
    provider       = oci.region1
    drg_id = oci_core_drg.test_drg_mumbai.id
    network_details {
        #Required
        id = oci_core_vcn.test_vcn_mumbai.id
        type = "REMOTE_PEERING_CONNECTION"
        route_table_id = oci_core_route_table.privateRT_mumbai.id
    }
}

resource "oci_core_remote_peering_connection" "test_remote_peering_connection_mumbai" {
    #Required
    provider       = oci.region1
    compartment_id = var.compartment_ocid
    drg_id = oci_core_drg.test_drg_mumbai.id

    #Optional
    peer_id = oci_core_remote_peering_connection.test_remote_peering_connection2.id
    peer_region_name = var.remote_peering_connection_peer_region_name
}

#resource block for public  route table with route rule 
resource "oci_core_route_table" "publicRT_mumbai" {
provider       = oci.region1
vcn_id = oci_core_vcn.test_vcn_mumbai.id
compartment_id = var.compartment_ocid
display_name = "public_route_table"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.test_internet_gateway_mumbai.id
  }
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_drg.test_drg_mumbai.id
  }
}

# #resource block for private route table 
resource "oci_core_route_table" "privateRT_mumbai"{
provider       = oci.region1
compartment_id = var.compartment_ocid
vcn_id = oci_core_vcn.test_vcn_mumbai.id
display_name = "private_route_table"
route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.test_nat_gateway_mumbai.id
  }
 
route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_drg.test_drg_mumbai.id
  }
}


#resource block for public security list
resource "oci_core_security_list" "publicSL_mumbai" {
  provider       = oci.region1
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.test_vcn_mumbai.id
  display_name   = "public_security_list"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
    
   ingress_security_rules {
    protocol = "6"
    source   = "10.0.0.0/16"
  }
    
  ingress_security_rules {
    protocol = "6"
    source   = "192.168.0.0/16"
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
    source   = "172.0.0.0/16"
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
resource "oci_core_security_list" "privateSL_mumbai" {
  provider       = oci.region1
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.test_vcn_mumbai.id
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
    source   = "172.0.0.0/16"
  }
  #for remote peering connections
  ingress_security_rules {
    protocol = "6"
    source   = "10.0.0.0/16"
  }
    
  ingress_security_rules {
    protocol = "6"
    source   = "192.168.0.0/16"
  }
    
     ingress_security_rules {
    tcp_options {
      max = "22"
      min = "22"
    }

    protocol = "6"
    source   = "172.0.0.0/16"
  }
  ingress_security_rules {
    tcp_options {
      max = "1521"
      min = "1521"
    }

    protocol = "6"
    source   = "172.0.0.0/16"
    }
    
  ingress_security_rules {
    icmp_options {
      type = "3"
    }

    protocol = "1"
    source   = "172.0.0.0/16"
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

