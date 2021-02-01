#!/bin/bash
set -e

script_dir=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
if [ ! -e $script_dir/.configured ]; then
    if [ -e $script_dir/venv ]; then
        echo "Ansible wasn't fully installed. Starting over..."
        rm -rf $script_dir/venv
    fi
fi

if [ ! -e $script_dir/venv ]; then
    echo "Installing Ansible in a virtual environment..."
    python3 -m venv $script_dir/venv
    source $script_dir/venv/bin/activate
    pip3 install wheel
    pip3 install -r $script_dir/requirements.txt
    ansible-galaxy collection install oracle.oci
    deactivate
    touch $script_dir/.configured
else
    echo "Ansible is installed."
fi

if [ $# == 0 ]; then
    exit 0
fi

source $script_dir/venv/bin/activate
source $script_dir/../configuration_parameters_common/tf_vars.sh
export ANSIBLE_CONFIG=$script_dir/ansible.cfg
ansible-playbook -u opc --key-file=$TF_VAR_vm_ssh_private_key -e database_admin_password=$TF_VAR_database_admin_password -e project_name=$TF_VAR_project_name -e project_version=$TF_VAR_project_version -e webservice_port=$TF_VAR_webservice_port "$@"
deactivate
