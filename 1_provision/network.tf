# network.tf
# We'll need a virtual cloud network (VCN) which should use a private IP
# address range like 192.168.0.0/16
resource "oci_core_vcn" "vcn" {
    # We're going to create the network in the compartment created by the
    # iam.tf module.
    compartment_id = oci_identity_compartment.compartment.id
    cidr_block = "192.168.0.0/16"
    display_name = "${var.project_name}_vcn"
}


# Create an internet gateway for the VCN.
resource "oci_core_internet_gateway" "internet_gateway" {
    display_name = "${var.project_name}_gateway"
    compartment_id = oci_identity_compartment.compartment.id
    vcn_id = oci_core_vcn.vcn.id
}


# All outgoing traffic will be routed via the internet gateway
resource "oci_core_route_table" "route_table" {
    display_name = "${var.project_name}_route_table"
    compartment_id = oci_identity_compartment.compartment.id
    vcn_id = oci_core_vcn.vcn.id
    route_rules {
      destination_type = "CIDR_BLOCK"
      destination = "0.0.0.0/0"
      network_entity_id = oci_core_internet_gateway.internet_gateway.id
    }
}


# Allow traffic from the internet to connect via TCP (protocol=6)
# on port 22 (SSH). We also allow traffic to HTTP port used by
# our web service but only from the load balancer subnet.
# We allow all ioutgoingtraffic that originates from the VMs (which
# is a little promiscuous).
resource "oci_core_security_list" "instance_security_list" {
    display_name = "${var.project_name}_instance_security_rules"
    compartment_id = oci_identity_compartment.compartment.id
    vcn_id = oci_core_vcn.vcn.id
    ingress_security_rules {
        stateless = false
        # Allow traffic to the web service port only from the LB
        # Change this to 0.0.0.0/0 if you want to test the individual
        # VM web services.
        source = "192.168.1.0/24"
        protocol = "6"
        tcp_options {
            max = var.webservice_port
            min = var.webservice_port
        }
    }
    ingress_security_rules {
        # Allow SSH traffic from anywhere.
        stateless = false
        source = "0.0.0.0/0"
        protocol = "6"
        tcp_options {
            max = 22
            min = 22
        }
    }
    egress_security_rules {
        # Allow all outgoing traffic. In practice we need to
        # connect to a database and to a yum repository.
        stateless = false
        destination = "0.0.0.0/0"
        protocol = "all"
    }
}


# Create a subnet for the instances and set the routing rules
# and security list for the instance subnet.
resource "oci_core_subnet" "instance_subnet" {
    display_name = "${var.project_name}_instance_subnet"
    compartment_id = oci_identity_compartment.compartment.id
    cidr_block = "192.168.0.0/24"
    vcn_id = oci_core_vcn.vcn.id
    route_table_id = oci_core_route_table.route_table.id
    security_list_ids = [ oci_core_security_list.instance_security_list.id ]
}


# The only ingress traffic allowed to the LB is to the LB port.
# The only egress traffic is to the web services running on the VMs.
resource "oci_core_security_list" "load_balancer_security_list" {
    display_name = "${var.project_name}_load_balancer_security_rules"
    compartment_id = oci_identity_compartment.compartment.id
    vcn_id = oci_core_vcn.vcn.id
    ingress_security_rules {
        stateless = false
        source = "0.0.0.0/0"
        protocol = "6"
        tcp_options {
            max = var.load_balancer_port
            min = var.load_balancer_port
        }
    }
    egress_security_rules {
        stateless = false
        destination = "192.168.0.0/24"
        protocol = "6"
        tcp_options {
            max = var.webservice_port
            min = var.webservice_port
        }
    }
}


# Create a subnet for the load balancer and set the routing rules
# and security list for the load balancer subnet.
resource "oci_core_subnet" "load_balancer_subnet" {
    display_name = "${var.project_name}_load_balancer_subnet"
    compartment_id = oci_identity_compartment.compartment.id
    cidr_block = "192.168.1.0/24"
    vcn_id = oci_core_vcn.vcn.id
    route_table_id = oci_core_route_table.route_table.id
    security_list_ids = [ oci_core_security_list.load_balancer_security_list.id ]
}
