#!/bin/bash
set -e

script_dir=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Provision the infrastructure
cd $script_dir/1_provision
source $script_dir/configuration_parameters_common/tf_vars.sh
terraform init
terraform destroy --auto-approve
terraform apply --auto-approve

# Configure the servers
$script_dir/ansible_common/ap.sh $script_dir/2_configure/configure.yml

# Deploy the application to the servers
$script_dir/ansible_common/ap.sh $script_dir/3_deploy/deploy.yml

# It's useful to know the IP address of our web service.
cd $script_dir/1_provision
terraform show | grep ^load_balancer_ip
