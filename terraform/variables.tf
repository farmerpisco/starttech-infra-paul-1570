variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
}

variable "project_name" {
  description = "Project name for all resources"
  type        = string
}

variable "cidr_block" {
  description = "CIDR Block for the VPC"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "docker_image" {
  description = "Docker image name for the application"
  type        = string
}

variable "mongo_username" {
  description = "MongoDB root username"
  type        = string
}

variable "mongo_password" {
  description = "MongoDB root password"
  type        = string
}
