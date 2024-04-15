# acs-730-repo-project-group11


## README.md
## Instructions to deploy the Autoscaling group with terraform and anisble.

Pre requisite
create an alias for the ease of use the command terraform.

alias tf=terraform

1) Need to create the sotrage buckets prior to implement this solution.

***If the bucket names should be changed according to your requirement, please refer to the files below prior to execute the commands.
```
  i) terraform/backend/stag.s3.tfbackend  --the bucket name mentoined in the terraform/STAGE/dynamodb/s3_backend_buckets.tf should be updated here
 ii) terraform/backend/prod.s3.tfbackend  --the bucket name mentoined in the terraform/STAGE/dynamodb/s3_backend_buckets.tf should be updated here
iii) terraform/STAGE/alb/config.tf --the bucket name mentoined in the terraform/STAGE/dynamodb/s3_backend_buckets.tf should be updated here
 iv) terraform/STAGE/dynamodb/image_store.tf
  v) terraform/STAGE/dynamodb/s3_backend_buckets.tf
 vi) ansible/roles/s3_upload/tasks/main.yml   --the bucket name mentoined in the terraform/STAGE/dynamodb/image_store.tf should be updated here
vii) terraform/STAGE/alb/main.tf  --the bucket name mentoined in the terraform/STAGE/dynamodb/s3_backend_buckets.tf should be updated here in line 21

```

--- Create the s3 buckets and dynamodb table

```
cd terraform/STAGE/dynamodb
tf init
tf validate
tf plan
tf apply --auto-approve
```

-- This will create the necessary storage buckets for remote tfstate file storage as well as image upload.


2) Need to create below ssh keys from the respective path

```
cd terraform/STAGE/alb
ssh-keygen -t rsa -f asg
ssh-keygen -t rsa -f bastion
```

3) Copy the ssh keys to the .ssh folder in your home directory.

```
cd terraform/STAGE/alb
cp -pfr asg ~/.ssh/
cp -pfr bastion ~/.ssh/
```

<strong>NETWORK LAYER</strong>

When creating the network infrastructure for the required environment, please use the below backend config files.

```
prod environment:  terraform/backend/stag.s3.tfbackend
stage environment: terraform/backend/prod.s3.tfbackend
```

<strong>Start with below commands.</strong>

Terraform initialisation
-------------------------
```
cd terraform
prod: terraform init  -backend-config=./backend/stag.s3.tfbackend
```
```
cd terraform
stage: terraform init  -backend-config=./backend/prod.s3.tfbackend
```
Terraform Plan
-------------------------
```
cd terraform
stage: terraform plan -var-file=./tfvars/stag.tfvars
```
```
cd terraform
prod:  terraform plan -var-file=./tfvars/prod.tfvars
```
Terraform Apply
--------------------------
```
cd terraform
stage: terraform apply -var-file=./tfvars/stag.tfvars
```
```
cd terraform
prod: terraform apply -var-file=./tfvars/prod.tfvars
```

<strong>Application server layer </strong>

</strong>#--STAGE</strong>
```
cd terraform/STAGE/alb
tf init
tf validate
tf plan -var env=stage
tf apply -var env=stage --auto-approve
```
</strong>#--PROD</strong>
```
cd terraform/STAGE/alb
tf init
tf validate
tf plan -var env=prod
tf apply -var env=prod --auto-approve
```

<strong> Ansible Automation for web server config </strong>

```
cd ansible
ansible-playbook -i aws_ec2.yaml master_play.yml
```

#If you need to desotry the environment plese follow the below steps.

</strong>#--STAGE</strong>
```
cd terraform/STAGE/alb
tf destroy -var env=prod --auto-approve
```
```
cd terraform
stage: terraform destroy -var-file=./tfvars/stag.tfvars
```
</strong>#--PROD</strong>
```
cd terraform/STAGE/alb
tf destroy -var env=prod --auto-approve
```
```
cd terraform
prod: terraform destroy -var-file=./tfvars/prod.tfvars
```
cd terraform/STAGE/dynamodb
tf destroy --auto-approve

**The end**
