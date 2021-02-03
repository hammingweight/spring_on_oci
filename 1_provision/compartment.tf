# compartment.tf
resource "oci_identity_compartment" "compartment" {
    compartment_id = var.tenancy_ocid
    description = "Compartment for ${var.project_name}."
    name = var.project_name
}

output "compartment_ocid" {
    value = oci_identity_compartment.compartment.id
}
