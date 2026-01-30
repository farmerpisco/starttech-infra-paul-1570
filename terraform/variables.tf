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
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "docker_image" {
  description = "Docker image name for the application"
  type = string
  default = "thefemipaul/starttech-app:latest"
}

variable "mongo_username" {
  description = "MongoDB root username"
  type        = string
  default     = "goappuser"
}

variable "mongo_password" {
  description = "MongoDB root password"
  type        = string
  default     = "goapppass"
}

#
