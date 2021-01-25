set -e

cd 1_provision
source tf_vars.sh
terraform init
terraform destroy --auto-approve
terraform apply --auto-approve

cd ../ansible_common
source venv/bin/activate
export ANSIBLE_CONFIG=$PWD/ansible.cfg

ap() {
    ansible-playbook -e database_admin_password=$TF_VAR_database_admin_password -e project_name=$TF_VAR_project_name -e webservice_port=$TF_VAR_webservice_port "$@"
}

cd ../2_configure
ap configure.yml
cd ../3_deploy
ap deploy.yml

# It's useful to know the IP address of our web service.
cd ../1_provision
terraform show | grep ^load_balancer_ip
