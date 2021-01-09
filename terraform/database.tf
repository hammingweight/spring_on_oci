resource "oci_database_autonomous_database" "project_autonomous_database" {
    compartment_id = oci_identity_compartment.project_compartment.id
    cpu_core_count = 1
    data_storage_size_in_tbs = 1
    db_name = var.project_name

    admin_password = var.database_admin_password
    display_name = "${var.project_name}_adb"
    is_free_tier = true
}
