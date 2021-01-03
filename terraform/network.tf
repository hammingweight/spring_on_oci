# We'll need a virtual cloud network (VCN) which should use a private IP
# address range like 192.168.0.0/16
resource "oci_core_vcn" "project_vcn" {
    # We're going to create the network in the compartment created by the
    # iam.tf module.
    compartment_id = oci_identity_compartment.project_compartment.id
    cidr_block = "192.168.0.0/16"
    display_name = "${var.project_name}_vcn"
}

# We'll create a subnet within the VCN for our VMs.
# We'll also need to specify how traffic is to be routed and
# security rules for the subnet.
resource "oci_core_subnet" "project_subnet" {
    display_name = "${var.project_name}_subnet"
    compartment_id = oci_identity_compartment.project_compartment.id
    cidr_block = "192.168.0.0/24"
    vcn_id = oci_core_vcn.project_vcn.id
    route_table_id = oci_core_route_table.project_route_table.id
    security_list_ids = [ oci_core_security_list.project_security_list.id ]
}

# Define a route table that has one rule that routes all traffic via an
# internet gateway.
resource "oci_core_route_table" "project_route_table" {
    display_name = "${var.project_name}_route_table"
    compartment_id = oci_identity_compartment.project_compartment.id
    vcn_id = oci_core_vcn.project_vcn.id
    route_rules {
      destination_type = "CIDR_BLOCK"
      destination = "0.0.0.0/0"
      network_entity_id = oci_core_internet_gateway.project_internet_gateway.id
    }
}

# Create an internet gateway.
resource "oci_core_internet_gateway" "project_internet_gateway" {
    display_name = "${var.project_name}_gateway"
    compartment_id = oci_identity_compartment.project_compartment.id
    vcn_id = oci_core_vcn.project_vcn.id
}

# Allow traffic from the internet to connect via TCP (protocol=6)
# on ports 22 (SSH) and the HTTP port used by our web service.
# We also let through all traffic that originates from the VMs.
resource "oci_core_security_list" "project_security_list" {
    display_name = "${var.project_name}_security_rules"
    compartment_id = oci_identity_compartment.project_compartment.id
    vcn_id = oci_core_vcn.project_vcn.id
    ingress_security_rules {
        stateless = false
        source = "0.0.0.0/0"
        protocol = "6"
        tcp_options {
            max = 8000
            min = 8000
        }
    }
    ingress_security_rules {
        stateless = false
        source = "0.0.0.0/0"
        protocol = "6"
        tcp_options {
            max = 22
            min = 22
        }
    }
    egress_security_rules {
        stateless = false
        destination = "0.0.0.0/0"
        protocol = "all"
    }
}

