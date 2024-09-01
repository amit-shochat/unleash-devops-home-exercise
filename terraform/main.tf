provider "aws" {
  region = var.region
}

# Create VPC 
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs            = var.vpc_azs
  public_subnets = var.vpc_public_subnets

  tags = var.vpc_tag
}

# Create the S3 bucket 
resource "aws_s3_bucket" "express_bucket" {
  bucket        = var.bucket_name
  force_destroy = var.bucket_force_destroy

  lifecycle {
    create_before_destroy = true
  }

  tags = var.vpc_tag
}

# Create the secury group for the ALB 
module "sg_alb" {
  source = "./modules/sg"

  sg_name        = var.alb_sg_name
  sg_description = "controls access to the ALB"

  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks_list = var.ingress_cidr_blocks_list
  ingress_app_port         = var.ingress_app_port
  ingress_protocol         = var.ingress_protocol

  egress_cidr_blocks_list = var.egress_cidr_blocks_list
  egress_app_port         = var.egress_app_port
  egress_protocol         = var.egress_protocol

}

# Create the secury group for the ECS
module "sg_ecs" {
  source = "./modules/sg"

  sg_name        = var.ecs_sg_name
  sg_description = "controls access to the ECS"

  vpc_id = module.vpc.vpc_id

  ingress_app_port        = var.ingress_app_port
  ingress_protocol        = var.ingress_protocol
  ingress_security_groups = [module.sg_alb.sg_id]

  egress_cidr_blocks_list = var.egress_cidr_blocks_list
  egress_app_port         = var.egress_app_port
  egress_protocol         = var.egress_protocol

}

# Create the load balancer 
module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  sg_list_ids       = [module.sg_alb.sg_id]
  subnets_id_list   = module.vpc.public_subnets
  app_name          = var.app_name
  health_check_path = var.health_check_path
  ingress_app_port  = var.ingress_app_port

}

# Create user for ECS and S3 
module "iam" {
  source = "./modules/iam"

  ecs_task_execution_role = var.ecs_task_execution_role
  bucket_name             = var.bucket_name
  iam_user                = var.iam_user
}

# Create the ECS 
module "ecs" {
  source               = "./modules/ecs"
  cluster_name         = var.ecs_cluster_name
  service_name         = var.ecs_service_name
  app_count            = var.app_count
  app_image            = var.app_image
  app_port             = var.ingress_app_port
  fargate_memory       = var.fargate_memory
  fargate_cpu          = var.fargate_cpu
  aws_region           = var.region
  alb_target_group_arn = module.alb.aws_target_group_arn
  sg_ecs_id            = module.sg_ecs.sg_id
  subnets_id_list      = module.vpc.public_subnets
  app_name             = var.app_name
  bucket_name          = var.bucket_name
  depends_on           = [module.alb.aws_alb_listener, module.iam]
  execution_role_arn   = module.iam.ecs_task_execution_role_arn
  task_role_arn        = module.iam.ecs_task_role_arn
}

module "autoscale" {
  source           = "./modules/autoscale"
  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name
}

module "cloudwatch" {
  source         = "./modules/cloudwatch"
  log_group_name = "${var.app_name}-container"
}
