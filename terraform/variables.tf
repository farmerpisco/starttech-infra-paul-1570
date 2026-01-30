variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name for all resources"
  type        = string
  default     = "starttech"
}

variable "cidr_block" {
  description = "CIDR Block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "key_name" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
  default     = "AltSchoolDemo"
}

variable "vpc_id" {
  description = "VPC ID for the compute module"
  type        = string
  default     = module.networking.st_vpc_id
}

variable "st_sg_id" {
  description = "Security group ID for the compute module"
  type        = string
  default     = module.networking.st_sg_id
}

variable "st_alb_sg_id" {
  description = "Security group ID for the ALB in the compute module"
  type        = string
  default     = module.networking.st_alb_sg_id
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for the compute module"
  type        = string
  default     = module.monitoring.st_ec2_profile_name
}

variable "private_subnets_ids" {
  description = "Private subnets IDs for the compute module"
  type        = list(string)
  default     = module.networking.st_private_subnets_ids
}

variable "public_subnets_ids" {
  description = "Public subnets IDs for the compute module"
  type        = list(string)
  default     = module.networking.st_public_subnets_ids
}

variable "redis_sg_id" {
  description = "Security group ID for Redis in the storage module"
  type        = string
  default     = module.networking.redis_sg_id
}