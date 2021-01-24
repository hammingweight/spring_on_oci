To set up Ansible and its dependencies, run the following in this directory
```
python3 -m venv venv
source venv/bin/activate
pip install ansible
pip install oci
ansible-galaxy collection install oracle.oci
```
