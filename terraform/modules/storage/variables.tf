variable "project_name" {
  description = "Name of the project for all resources"
  type        = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "redis_sg_id" {
  type = string
}