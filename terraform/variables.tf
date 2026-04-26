# File: terraform/variables.tf
# All configurable parameters for Terraform

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project (used for naming all resources)"
  type        = string
  default     = "online-boutique"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m7i-flex.large"
  # Options: t3.small (1 vCPU, 2GB RAM), t3.medium (1 vCPU, 4GB RAM), 
  #          t3.large (2 vCPU, 8GB RAM), t3.xlarge (4 vCPU, 16GB RAM)
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 30
}

variable "key_pair_name" {
  description = "Name of the EC2 key pair to use for SSH access"
  type        = string
  default     = "online-boutique"
  # IMPORTANT: This key pair must already exist in your AWS account
  # Create it in AWS Console: EC2 → Key Pairs → Create Key Pair
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring"
  type        = bool
  default     = true
}

