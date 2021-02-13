#!/bin/bash
set -e

# A very simple wrapper around terraform that populates the
# environment vraiables before invoking terraform.
script_dir=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source $script_dir/../configuration_parameters_common/tf_vars.sh
terraform $@
