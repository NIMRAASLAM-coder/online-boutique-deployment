# File: terraform/terraform.tfvars
# Values for Terraform variables - customize as needed

aws_region        = "us-east-1"
project_name      = "online-boutique"
environment       = "dev"
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
instance_type     = "m7i-flex.large"
root_volume_size  = 30
key_pair_name     = "online-boutique"

# IMPORTANT: Before running terraform apply:
# 1. Change "online-boutique" to the name of your EC2 key pair
# 2. The key pair must exist in AWS Console already
# 3. If you don't have a key pair, create one:
#    - AWS Console → EC2 → Key Pairs → Create Key Pair
#    - Download the .pem file
#    - Save to ~/.ssh/online-boutique.pem
#    - chmod 600 ~/.ssh/online-boutique.pem

