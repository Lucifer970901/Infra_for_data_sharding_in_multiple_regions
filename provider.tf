provider "oci" {
  alias            = "home"
  version          = ">=3.11"
  tenancy_ocid     = var.tenancy_ocid
  region           = var.region
}

provider "oci" {
  alias            = "region1"
  version          = ">=3.11"
  tenancy_ocid     = var.tenancy_ocid
  region           = var.region
}

provider "oci" {
  alias            = "region2"
  version          = ">=3.11"
  tenancy_ocid     = var.tenancy_ocid
  region           = var.region
}
