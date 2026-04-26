# File: terraform/outputs.tf
# Outputs displayed after terraform apply

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.k8s_master.id
}

output "ec2_private_ip" {
  description = "Private IP address of EC2 instance"
  value       = aws_instance.k8s_master.private_ip
}

output "ec2_public_ip" {
  description = "Public IP address of EC2 instance (Elastic IP)"
  value       = aws_eip.k8s_master.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.k8s_master.public_dns
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.ec2.id
}

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ubuntu@${aws_eip.k8s_master.public_ip}"
}

output "key_pair_name" {
  description = "EC2 key pair name"
  value       = var.key_pair_name
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

