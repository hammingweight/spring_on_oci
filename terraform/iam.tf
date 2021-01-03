# iam.tf
resource "oci_identity_compartment" "project_compartment" {
    compartment_id = var.tenancy_ocid
    description = "Compartment for ${var.project_name}."
    name = var.project_name
}
