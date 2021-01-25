# load_balancer.tf
resource "oci_load_balancer_load_balancer" "load_balancer" {
    compartment_id = oci_identity_compartment.compartment.id
    display_name = "${var.project_name}_load_balancer"
    shape = "flexible"
    shape_details {
        maximum_bandwidth_in_mbps=var.load_balancer_bandwidth_in_mbps
        minimum_bandwidth_in_mbps=var.load_balancer_bandwidth_in_mbps
    }
    subnet_ids = [ oci_core_subnet.load_balancer_subnet.id ]
}

resource "oci_load_balancer_backend_set" "backend_set" {
    name = "${var.project_name}_backend_set"
    health_checker {
        protocol = "HTTP"

        port = var.webservice_port
        url_path = var.webservice_healthcheck_url
    }
    load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
    policy = "ROUND_ROBIN"
}

resource "oci_load_balancer_certificate" "certificate" {
    certificate_name = "${var.project_name}_certificate"
    load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
    private_key = file("../configuration_parameters_common/lb_key.pem")
    public_certificate = file("../configuration_parameters_common/lb_cert.pem")
    lifecycle {
        create_before_destroy = true
    }
}

resource "oci_load_balancer_listener" "load_balancer_listener" {
    default_backend_set_name = oci_load_balancer_backend_set.backend_set.name
    load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
    name = "${var.project_name}_load_balancer_listener"
    port = var.load_balancer_port
    protocol = "HTTP"
    ssl_configuration {
        certificate_name = oci_load_balancer_certificate.certificate.certificate_name
        verify_peer_certificate = false
    }
}

output "load_balancer_ip" {
    value = oci_load_balancer_load_balancer.load_balancer.ip_address_details[0].ip_address
}
