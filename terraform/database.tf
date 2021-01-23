resource "oci_database_autonomous_database" "autonomous_database" {
    compartment_id = oci_identity_compartment.project_compartment.id
    cpu_core_count = 1
    data_storage_size_in_tbs = 1
    db_name = var.project_name

    admin_password = var.database_admin_password
    display_name = "${var.project_name}_adb"
    is_free_tier = true
}

resource "oci_database_autonomous_database_wallet" "autonomous_database_wallet" {
    #Required
    autonomous_database_id = oci_database_autonomous_database.autonomous_database.id
    password = var.database_wallet_password
    base64_encode_content = true
    generate_type = "SINGLE"
}

resource "local_file" "database_wallet_zip" {
    content = oci_database_autonomous_database_wallet.autonomous_database_wallet.content
    filename = "database_wallet.zip.asc"
}
