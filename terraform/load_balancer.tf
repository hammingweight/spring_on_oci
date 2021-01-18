# load_balancer.tf
resource "oci_load_balancer_load_balancer" "project_load_balancer" {
    compartment_id = oci_identity_compartment.project_compartment.id
    display_name = "${var.project_name}_load_balancer"
    shape = "flexible"
    shape_details {
        maximum_bandwidth_in_mbps=var.load_balancer_bandwidth_in_mbps
        minimum_bandwidth_in_mbps=var.load_balancer_bandwidth_in_mbps
    }
    subnet_ids = [ oci_core_subnet.project_load_balancer_subnet.id ]
}

resource "oci_load_balancer_backend_set" "project_backend_set" {
    health_checker {
        protocol = "HTTP"

        port = var.webservice_port
        url_path = var.webservice_healthcheck_url
    }
    load_balancer_id = oci_load_balancer_load_balancer.project_load_balancer.id
    name = "${var.project_name}_backend_set"
    policy = "ROUND_ROBIN"
}

resource "oci_load_balancer_listener" "project_load_balancer_listener" {
    default_backend_set_name = oci_load_balancer_backend_set.project_backend_set.name
    load_balancer_id = oci_load_balancer_load_balancer.project_load_balancer.id
    name = "${var.project_name}_load_balancer_listener"
    port = var.load_balancer_port
    protocol = "HTTP"
}
