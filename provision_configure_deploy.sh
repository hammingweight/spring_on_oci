#!/bin/bash
set -e

script_dir=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

if [ ! -e $script_dir/configuration_parameters_common/tf_vars.sh ]
then
    cp $script_dir/configuration_parameters_common/tf_vars.sh.tmpl $script_dir/configuration_parameters_common/tf_vars.sh
fi

# Provision the infrastructure
cd $script_dir/1_provision
source $script_dir/configuration_parameters_common/tf_vars.sh
echo "Provisioning servers, a load balancer and a database..."
terraform init
terraform destroy --auto-approve
terraform apply --auto-approve

# Configure the servers
echo "Configuring the servers..."
$script_dir/ansible_common/ap.sh $script_dir/2_configure/configure.yml

# Deploy the application to the servers
echo "Deploying Spring Boot service to the servers..."
$script_dir/ansible_common/ap.sh $script_dir/3_deploy/deploy.yml

# It's useful to know the IP address of our web service.
cd $script_dir/1_provision
terraform show | grep ^load_balancer_ip
