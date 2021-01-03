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

resource "oci_load_balancer_load_balancer" "project_load_balancer" {
    compartment_id = oci_identity_compartment.project_compartment.id
    display_name = "${var.project_name}_load_balancer"
    shape = "flexible"
    shape_details {
        maximum_bandwidth_in_mbps=var.load_balancer_bandwidth_in_mbps
        minimum_bandwidth_in_mbps=var.load_balancer_bandwidth_in_mbps
    }
    subnet_ids = [ oci_core_subnet.project_subnet.id ]
}
