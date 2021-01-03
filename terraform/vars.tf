# vars.tf
variable region {}

variable tenancy_ocid {}

variable user_ocid {}

variable private_key_path {}

variable fingerprint {}

variable vm_ssh_key {}

variable shape {
    default="VM.Standard.E2.1.Micro"
}

variable image_ocid {
    default = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaf6gm7xvn7rhll36kwlotl4chm25ykgsje7zt2b4w6gae4yqfdfwa"
}

variable webservice_port {
    default = 8080
}

variable project_name {
    default = "demo"
}
