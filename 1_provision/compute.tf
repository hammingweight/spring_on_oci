# compute.tf

# This emits a list of all images that match a specified
# display name.
data "oci_core_images" "images" {
    compartment_id = oci_identity_compartment.compartment.id
    operating_system = var.image_operating_system
    operating_system_version = var.image_operating_system_version
    sort_by = "TIMECREATED"
    sort_order = "DESC"
}


# This emits the availability domains in the operator's region.
data "oci_identity_availability_domains" "ads" {
    compartment_id = oci_identity_compartment.compartment.id
}


# Create an "instance configuration" that will be used as a
# template for instances where all instances will use the same
# shape, SSH key and the first image emitted by the directive
# above.
resource "oci_core_instance_configuration" "instance_configuration" {
    compartment_id = oci_identity_compartment.compartment.id
    freeform_tags = {"${var.project_name}_instance"= true}
    instance_details {
        instance_type = "compute"
        launch_details {
            compartment_id = oci_identity_compartment.compartment.id
            create_vnic_details {
                assign_public_ip = true
            }
            metadata = {
                ssh_authorized_keys = file(var.vm_ssh_key)
            }
            shape = var.shape
            source_details {
                source_type = "image"
                image_id = data.oci_core_images.images.images[0].id
            }
        }
    }
    display_name = "${var.project_name}_instance_config"
}


# Create a pool of instances based on the instance configuration
# in a specified VCN subnet and where the instances should be
# fronted by the load alancer created in load_balancer.tf
resource "oci_core_instance_pool" "instance_pool" {
    compartment_id = oci_identity_compartment.compartment.id
    instance_configuration_id = oci_core_instance_configuration.instance_configuration.id
    placement_configurations {
        availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.ad_number - 1].name
        primary_subnet_id = oci_core_subnet.instance_subnet.id
    }
    size = var.number_of_instances
    display_name = "${var.project_name}_instance_pool"
    load_balancers {
        backend_set_name = oci_load_balancer_backend_set.backend_set.name
        load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
        port = var.webservice_port
        vnic_selection = "PrimaryVnic"
    }
}
