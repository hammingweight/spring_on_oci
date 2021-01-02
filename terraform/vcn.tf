resource "oci_core_vcn" "test_vcn" {
    compartment_id = var.compartment_ocid

    cidr_block = "192.168.0.0/16"
    display_name = "test_vcn"
}

resource "oci_core_subnet" "test_subnet" {
    compartment_id = var.compartment_ocid

    cidr_block = "192.168.1.0/24"
    display_name = "test_subnet"
    vcn_id = oci_core_vcn.test_vcn.id
    security_list_ids = [ oci_core_security_list.test_seclist.id ]
}

resource "oci_core_security_list" "test_seclist" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.test_vcn.id
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
}

resource "oci_core_internet_gateway" "test_internet_gateway" {
    #Required
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.test_vcn.id
}
