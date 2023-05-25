
resource "oci_core_vcn" "test_vcn" {
    #Required
    provider       = oci.home
    cidr_block = var.vcn_cidr_block
    compartment_id = oci_identity_compartment.asset_compartment.id
    display_name = var.display_name_vcn
    dns_label = var.vcn_dns_label
}

#resource block for defining public subnet
resource "oci_core_subnet" "publicsubnet"{
provider       = oci.home
dns_label = "PublicSubnet"
compartment_id = oci_identity_compartment.asset_compartment.id
vcn_id = oci_core_vcn.test_vcn.id
display_name = var.display_name_publicsubnet
cidr_block = var.cidr_block_publicsubnet
route_table_id = oci_core_route_table.publicRT.id
security_list_ids = [oci_core_security_list.publicSL.id]
}

resource "oci_core_subnet" "privatesubnet"{
provider       = oci.home
dns_label = "PrivateSubnet"
compartment_id = oci_identity_compartment.asset_compartment.id
vcn_id = oci_core_vcn.test_vcn.id
display_name = var.display_name_privatesubnet
cidr_block = var.cidr_block_privatesubnet
prohibit_public_ip_on_vnic = "true"
route_table_id = oci_core_route_table.privateRT.id
security_list_ids = [oci_core_security_list.privateSL.id]
}

#resource block for internet gateway
resource "oci_core_internet_gateway" "test_internet_gateway" {
  provider       = oci.home
  compartment_id = oci_identity_compartment.asset_compartment.id
  vcn_id         = oci_core_vcn.test_vcn.id
}

resource "oci_core_nat_gateway" "test_nat_gateway" {
    #Required
    provider       = oci.home
    compartment_id =oci_identity_compartment.asset_compartment.id
    vcn_id = oci_core_vcn.test_vcn.id
}

#resource block for route table with route rule for internet gateway
resource "oci_core_route_table" "publicRT" {
provider       = oci.home
vcn_id = oci_core_vcn.test_vcn.id
compartment_id = oci_identity_compartment.asset_compartment.id
display_name = "public_route_table"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.test_internet_gateway.id
  }
}
# #resource block for private route table 
resource "oci_core_route_table" "privateRT"{
provider       = oci.home
compartment_id = oci_identity_compartment.asset_compartment.id
vcn_id = oci_core_vcn.test_vcn.id
display_name = "private_route_table"
route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.test_nat_gateway.id
  }
#route_rules {
 #   destination       = "0.0.0.0/0"
  #  network_entity_id = oci_core_service_gateway.test_service_gateway.id
  #}
}


#resource block for public security list
resource "oci_core_security_list" "publicSL" {
  provider       = oci.home
  compartment_id = oci_identity_compartment.asset_compartment.id
  vcn_id         = oci_core_vcn.test_vcn.id
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
    source   = "10.0.0.0/16"
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
resource "oci_core_security_list" "privateSL" {
  provider       = oci.home
  compartment_id = oci_identity_compartment.asset_compartment.id
  vcn_id         = oci_core_vcn.test_vcn.id
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
    source   = "10.0.0.0/16"
  }
  
  ingress_security_rules {
    tcp_options {
      max = "1521"
      min = "1521"
    }

    protocol = "6"
    source   = "10.0.0.0/16"
    }
    
  ingress_security_rules {
    icmp_options {
      type = "3"
    }

    protocol = "1"
    source   = "10.0.0.0/16"
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
