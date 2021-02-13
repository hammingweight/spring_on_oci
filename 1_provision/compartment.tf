# compartment.tf
# OCI supports "compartments" which provide a logical grouping
# for related resources rather than requiring that all objects
# be created in the tenancy.
resource "oci_identity_compartment" "compartment" {
    compartment_id = var.tenancy_ocid
    description = "Compartment for ${var.project_name}."
    name = var.project_name
}

# Many OCI CLI commands require the OCID of a compartment
# so we output the OCID to help the operator when they
# need to find the OCID. Running "terraform show" will
# emit the value.
output "compartment_ocid" {
    value = oci_identity_compartment.compartment.id
}
