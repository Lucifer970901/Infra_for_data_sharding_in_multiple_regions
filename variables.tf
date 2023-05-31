variable "tenancy_ocid"{}
variable "home_region"{}
variable "compartment_ocid"{}
variable "region1"{}
variable "region2"{}

#variables for vcn
variable "display_name_vcn_mumbai"{
  default = "Mumbai_VCN"
}
variable "display_name_vcn"{
  default = "Singapore_VCN"
}
variable "display_name_vcn_anz"{
  default = "Sydney_VCN"
}

variable "vcn_cidr_block_mumbai"{
  default = "172.0.0.0/16"
}
variable "vcn_cidr_block"{
  default = "10.0.0.0/16"
}
variable "vcn_cidr_block_anz"{
  default = "192.168.0.0/16"
}

variable "display_name_publicsubnet"{
  default = "public_subnet"
}
variable "display_name_privatesubnet"{
  default = "private_subnet"
}

variable "cidr_block_privatesubnet_mumbai"{
  default = "172.0.1.0/24"
}
variable "cidr_block_privatesubnet"{
  default = "10.0.1.0/24"
}
variable "cidr_block_privatesubnet_anz"{
  default = "192.168.1.0/24"
}

