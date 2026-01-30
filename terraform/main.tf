terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket         = "starttech-state-bucket"
    key            = "starttech/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "starttech-terraform-locks"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "networking" {
  source = "./modules/networking"

  cidr_block   = var.cidr_block
  project_name = var.project_name
}

module "compute" {
  source = "./modules/compute"

  project_name              = var.project_name
  key_name                  = var.key_name
  instance_type             = var.instance_type
  vpc_id                    = var.vpc_id
  st_sg_id                  = var.st_sg_id
  st_alb_sg_id              = var.st_alb_sg_id
  iam_instance_profile_name = var.iam_instance_profile_name
  private_subnets_ids       = var.private_subnets_ids
  public_subnets_ids        = var.public_subnets_ids
}

module "storage" {
  source = "./modules/storage"

  project_name       = var.project_name
  redis_sg_id        = var.redis_sg_id
  private_subnet_ids = var.private_subnets_ids
}

module "monitoring" {
  source = "./modules/monitoring"

  project_name = var.project_name
}