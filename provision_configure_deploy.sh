cd 1_provision
source tf_vars.sh
terraform init
terraform destroy --auto-approve
terraform apply --auto-approve

cd ../ansible
source venv/bin/activate

ap() {
    ansible-playbook -e database_admin_password=$TF_VAR_database_admin_password -e project_name=$TF_VAR_project_name -e webservice_port=$TF_VAR_webservice_port "$@"
}

ap configure.yml
ap database_schema.yml
ap deploy.yml
