# vars.tf
# Default values for these variables are defined in
# tf_vars.sh.tmpl.
variable tenancy_ocid {}

variable config_file_profile {}

variable vm_ssh_key {}

variable shape {}

variable image_operating_system {}

variable image_operating_system_version {}

variable load_balancer_bandwidth_in_mbps {}

variable load_balancer_port {}

variable load_balancer_key {}

variable load_balancer_cert {}

variable webservice_port {}

variable webservice_healthcheck_url {}

variable project_name {}

variable ad_number {}

variable number_of_instances {}

variable database_admin_password {}

variable database_wallet_password {}
