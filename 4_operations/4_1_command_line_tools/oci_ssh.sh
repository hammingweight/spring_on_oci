#!/bin/bash
set -e

if [ $# != 1 ];
then
    echo "Usage: $0 <ip_address>"
    exit 1
fi

script_dir=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source $script_dir/../../configuration_parameters_common/tf_vars.sh 1>/dev/null 2>/dev/null
ssh -o  StrictHostKeyChecking=no -i $TF_VAR_vm_ssh_private_key opc@$1
