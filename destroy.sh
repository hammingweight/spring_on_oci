#!/bin/bash
set -e

script_dir=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

if [ ! -e $script_dir/configuration_parameters_common/tf_vars.sh ]
then
    cp $script_dir/configuration_parameters_common/tf_vars.sh.tmpl $script_dir/configuration_parameters_common/tf_vars.sh
fi

cd $script_dir/1_provision
source $script_dir/configuration_parameters_common/tf_vars.sh
terraform destroy
