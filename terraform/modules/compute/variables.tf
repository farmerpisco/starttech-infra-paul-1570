variable "project_name" {
  description = "Name of the project for all resources"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be deployed"
  type = string
}

variable "st_sg_id" {
  description = "Security Group ID for EC2 instances"
  type = string
}

variable "private_subnets_ids" {
  description = "List of private subnet IDs"
  type = list(string)
}

variable "public_subnets_ids" {
  description = "List of public subnet IDs"
  type = list(string)
}

variable "iam_instance_profile_name" {
  description = "IAM Instance Profile name for EC2 instances"
  type = string
}

variable "st_alb_sg_id" {
  description = "Security Group ID for the Application Load Balancer"
  type = string
}

variable "docker_image" {
  description = "Docker image name for the application"
  type = string
}

variable "mongo_username" {
  description = "MongoDB root username"
  type        = string
}

variable "mongo_password" {
  description = "MongoDB root password"
  type        = string
}

variable "aws_region" {
  description = "AWS region for the resources"
  type        = string
}