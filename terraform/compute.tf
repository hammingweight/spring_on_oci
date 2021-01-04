resource "oci_core_instance_configuration" "project_instance_configuration" {
    compartment_id = oci_identity_compartment.project_compartment.id
    instance_details {
        instance_type = "compute"
        launch_details {
            compartment_id = oci_identity_compartment.project_compartment.id
            create_vnic_details {
                assign_public_ip = true
            }
            metadata = {
                ssh_authorized_keys = file(var.vm_ssh_key)
            }
            shape = var.shape
            source_details {
                source_type = "image"
                image_id = var.image_ocid
            }
        }
    }
    display_name = "${var.project_name}_instance_config"
}

data "oci_identity_availability_domains" "ads" {
    compartment_id = oci_identity_compartment.project_compartment.id
}

resource "oci_core_instance_pool" "project_instance_pool" {
    compartment_id = oci_identity_compartment.project_compartment.id
    instance_configuration_id = oci_core_instance_configuration.project_instance_configuration.id
    placement_configurations {
        availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.ad_number - 1].name
        primary_subnet_id = oci_core_subnet.project_subnet.id
    }
    size = var.number_of_instances
    display_name = "${var.project_name}_instance_pool"
    load_balancers {
        backend_set_name = oci_load_balancer_backend_set.project_backend_set.name
        load_balancer_id = oci_load_balancer_load_balancer.project_load_balancer.id
        port = 8000
        vnic_selection = "PrimaryVnic"
    }
}
