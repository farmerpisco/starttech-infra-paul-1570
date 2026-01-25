variable "project_name" {
  description = "Name of the project for all resources"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "instance_type" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "st_sg_id" {
  type = string
}

variable "private_subnets_ids" {
  type = list(string)
}

variable "public_subnets_ids" {
  type = list(string)
}

variable "iam_instance_profile_name" {
  type = string
}

variable "st_alb_sg_id" {
  type = string
}