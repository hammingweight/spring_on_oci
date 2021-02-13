# load_balancer.tf
# Create a load balancer
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


# Create a backend set for the load balancer and specify how
# the load balancer should determine if the instances in the
# backend set are healthy.
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


# We'd like the load balancer to support SSL so we install an SSL key
# and certificate.
resource "oci_load_balancer_certificate" "certificate" {
    certificate_name = "${var.project_name}_certificate"
    load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
    private_key = file(var.load_balancer_key)
    public_certificate = file(var.load_balancer_cert)
    lifecycle {
        create_before_destroy = true
    }
}


# Specify the port that the load balancer should listen on.
resource "oci_load_balancer_listener" "load_balancer_listener" {
    load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
    default_backend_set_name = oci_load_balancer_backend_set.backend_set.name
    name = "${var.project_name}_load_balancer_listener"
    port = var.load_balancer_port
    protocol = "HTTP"
    ssl_configuration {
        certificate_name = oci_load_balancer_certificate.certificate.certificate_name
        verify_peer_certificate = false
    }
}


# Emit the IP address of the load balancer so that the operator doesn't have
# to trawl Terraform's logs to find it.
output "load_balancer_ip" {
    value = oci_load_balancer_load_balancer.load_balancer.ip_address_details[0].ip_address
}
