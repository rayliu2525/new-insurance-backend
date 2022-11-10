#################
# VPC variables
#################

variable "vpc_name" {}
variable "backend_region" {}
variable "owner" {}
variable "environment" {}
variable "vpc_cidr" {}
variable "vpc_azs"  {}
variable "vpc_public_subnets" {}
variable "vpc_private_subnets" {}
variable "vpc_database_subnets" {}

#################
# SG variables
#################

variable "sg_ingress_port" {}
variable "sg_ingress_protocol" {}

#################
# RDS variables
#################

variable "db_identifier" {}
variable "db_engine" {}
variable "db_engine_version" {}
variable "db_family" {}
variable "db_major_engine_version" {}
variable "db_instance_class" {}
variable "db_allocated_storage" {}
variable "db_max_allocated_storage" {}
variable "db_name" {}
variable "db_username" {}
variable "db_port" {}
variable "db_maintenance_window" {}
variable "db_backup_window" {}
variable "db_monitoring_interval" {}
variable "db_monitoring_role_name" {}
variable "db_create_monitoring_role" {}


locals {
  name   = var.vpc_name
  region = var.backend_region
  tags = {
    Owner       = var.owner
    Environment = var.environment
  }
}

provider "aws" {
  region = local.region
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = var.vpc_cidr

  azs              = var.vpc_azs
  public_subnets   = var.vpc_public_subnets
  private_subnets  = var.vpc_private_subnets
  database_subnets = var.vpc_database_subnets

  create_database_subnet_group = true

  tags = local.tags
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Complete MySQL example security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = var.sg_ingress_port
      to_port     = var.sg_ingress_port
      protocol    = var.sg_ingress_protocol
      description = "MySQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = local.tags
}

################################################################################
# RDS Module
################################################################################

module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = var.db_identifier

  engine               = var.db_engine
  engine_version       = var.db_engine_version
  family               = var.db_family
  major_engine_version = var.db_major_engine_version
  instance_class       = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage

  db_name  = var.db_name
  username = var.db_username
  port     = var.db_port

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window = var.db_maintenance_window
  backup_window      = var.db_backup_window

  monitoring_interval = var.db_monitoring_interval
  monitoring_role_name = var.db_monitoring_role_name
  create_monitoring_role = var.db_create_monitoring_role

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.vpc.database_subnets

  # Database Deletion Protection
  deletion_protection = false

  parameters = [
    {
      name = "character_set_client"
      value = "utf8mb4"
    },
    {
      name = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}