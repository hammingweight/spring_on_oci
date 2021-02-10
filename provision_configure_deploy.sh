#!/bin/bash
set -e

# Check that the user has installed the OCI CLI
if ! which oci
then
    echo "Please download and install the OCI CLI."
    echo "https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm"
    exit 1
fi

# Check that we have a Java compiler needed by Maven
if ! which javac
then
    echo "You need a Java compiler. Please install a JDK."
    exit 1
fi

# Get the path to this script
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
terraform apply --auto-approve

# Configure the servers
echo "Configuring the servers..."
$script_dir/ansible_common/ap.sh $script_dir/2_configure/configure.yml

# Deploy the application to the servers
echo "Creating database schema..."
$script_dir/ansible_common/ap.sh $script_dir/3_deploy/schema.yml
echo "Deploying Spring Boot service to the servers..."
$script_dir/ansible_common/ap.sh $script_dir/3_deploy/deploy.yml

# It's useful to know the IP address of our web service.
cd $script_dir/1_provision
terraform show | grep ^load_balancer_ip
