#################
# Region
#################
region = "eu-west-1"

#################
# VPC
#################
vpc_name = "express-bucket-vpc"
vpc_cidr = "10.0.0.0/16"
vpc_public_subnets = [
  "10.0.101.0/24",
  "10.0.102.0/24"
]
vpc_azs = [
    "eu-west-1a",
    "eu-west-1b"
]
vpc_tag = {
  App_Name    = "express-bucket",
  Terraform   = "true",
  Environment = "dev"
}


#################
# ALB
#################

ingress_cidr_blocks_list = ["0.0.0.0/0"]
egress_cidr_blocks_list  = ["0.0.0.0/0"]
ingress_app_port         = 3000
ingress_protocol         = "tcp"
egress_protocol          = "-1"

#################
# ECS && S3
#################
# S3
iam_user             = "ecs-s3-user"
bucket_force_destroy = true
bucket_name          = "express-bucket-3"

# ECS 
app_image         = "amitshochat66/express-bucket-app:7ebffde9d469927727dc7c70b4e4f31f73f7fb28"
app_name          = "express-bucket-2"
health_check_path = "/health"
fargate_cpu       = 256
fargate_memory    = 512
app_count         = 2


ecs_task_execution_role = "myECcsTaskExecutionRole"

ecs_cluster_name = "ecs-express-bucket-cluster"
ecs_service_name = "ecs-express-bucket-service"

ecs_sg_name = "ecs-express-bucket-sg"
alb_sg_name = "alb-express-bucket-sg"