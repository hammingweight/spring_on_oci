#!/bin/bash
set -e

# Running "ssh -i vm_ssh_key opc@ip_address." This script requires only
# the ip address and locates the key and adds the user.
if [ $# != 1 ];
then
    echo "Usage: $0 <ip_address>"
    exit 1
fi

script_dir=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
# Get the key location from the environment variables file.
source $script_dir/../../configuration_parameters_common/tf_vars.sh 1>/dev/null 2>/dev/null
ssh -o  StrictHostKeyChecking=no -i $TF_VAR_vm_ssh_private_key opc@$1
