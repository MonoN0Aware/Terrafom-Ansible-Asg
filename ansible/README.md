## README.me
## Instructions to deploy ansible process.

_**Pre requisite:**_
1) make sure the keys "asg" and "bastion" are copied to ~/.ssh path prior continueing with this step.
2) Make sure the _ansible/roles/s3_upload/tasks/main.yml_ is updated with the correct bucket name as in _terraform/STAGE/dynamodb/image_store.tf_

<strong> Ansible Automation for web server configuration </strong>

```
cd ansible
ansible-playbook -i aws_ec2.yaml master_play.yml
```

_Note: in the bash prompt, type 'yes' and enter three times when it prompts "Are you sure you want to continue connecting (yes/no)?" and After the scale-out operation when you are running the playbook again type 'yes' in the prompt_

**If the autoscale group increased the instance in case of a CPU spike, just run this playbook again. It will make the neccessary changes to the newly added instances without configuring the existing instances.**



