# provider.tf
# This minimal provider specification means that
# the OCI credentials will be read from the
# $HOME/.oci/config file.
provider "oci" {
    config_file_profile = var.config_file_profile
}
