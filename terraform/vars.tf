# vars.tf
variable region {
}

variable tenancy_ocid {
}

variable user_ocid {
}

variable private_key_path {
  default="./api_key.pem"
}

variable fingerprint {
}

variable webservice_port {
  default=8080
}

variable project_name {
  default="demo"
}
