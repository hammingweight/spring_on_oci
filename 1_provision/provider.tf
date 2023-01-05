# provider.tf
# This minimal provider specification means that
# the OCI credentials will be read from the
# $HOME/.oci/config file.
provider "oci" {
    config_file_profile = var.config_file_profile
}

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.0.0"
    }
  }
}
