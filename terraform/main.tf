provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket         = "cloudzenia-terraform-state"
    key            = "cloudzenia/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "cloudzenia-terraform-locks"
  }
}

module "vpc" {
  source    = "./modules/vpc"
  alb_sg_id = module.alb.alb_sg_id
}

module "rds" {
  source          = "./modules/rds"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  ecs_sg_id       = module.vpc.ecs_sg_id
  db_password     = var.db_password
}

module "secrets_manager" {
  source      = "./modules/secrets_manager"
  db_password = var.db_password
}

module "ecs" {
  source                        = "./modules/ecs"
  vpc_id                        = module.vpc.vpc_id
  private_subnets               = module.vpc.private_subnets
  ecs_sg_id                     = module.vpc.ecs_sg_id
  alb_sg_id                     = module.alb.alb_sg_id
  rds_endpoint                  = module.rds.rds_endpoint
  db_password_secret_arn        = module.secrets_manager.db_password_secret_arn
  wordpress_target_group_arn    = module.alb.wordpress_target_group_arn
  microservice_target_group_arn = module.alb.microservice_target_group_arn
  ecr_repository_url            = "631478160867.dkr.ecr.ap-south-1.amazonaws.com/microservice"
}

module "ec2" {
  source          = "./modules/ec2"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  alb_sg_id       = module.alb.alb_sg_id
}

module "alb" {
  source         = "./modules/alb"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  hosted_zone_id = "Z05135773VBNXAZ3YSQ5W"
}

module "observability" {
  source             = "./modules/observability"
  ecs_cluster_name   = module.ecs.ecs_cluster_name
  ec2_instance_ids   = module.ec2.ec2_instance_ids
  rds_instance_id    = module.rds.rds_instance_id
}

module "s3" {
  source         = "./modules/s3"
  hosted_zone_id = var.hosted_zone_id
}

module "budget" {
  source = "./modules/budget"
}
