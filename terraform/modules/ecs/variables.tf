variable "cluster_name" {
  description = "Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = ""
}

variable "app_image" {
  default     = ""
  description = "docker image to run in this ECS cluster"
}

variable "aws_region" {
  default     = ""
  description = "aws region where our resources going to create choose"
  #replace the region as suits for your requirement
}

variable "fargate_cpu" {
  type        = number
  description = "fargate instacne CPU units to provision,my requirent 1 vcpu so gave 1024"
}

variable "fargate_memory" {
  type        = number
  description = "Fargate instance memory to provision (in MiB) not MB"
}

variable "app_port" {
  type        = number
  default     = 0
  description = "portexposed on the docker image"
}

variable "app_count" {
  type        = number
  description = "numer of docker containers to run"
}

variable "execution_role_arn" {
  type        = string
  default     = ""
  description = "description"
}

variable "alb_target_group_arn" {
  type        = string
  default     = ""
  description = "description"
}

variable "sg_ecs_id" {
  type        = string
  default     = ""
  description = "description"
}

variable "subnets_id_list" {
  description = "id of exsisting subnets"
  type        = list(string)
  default     = []
}

variable "service_name" {
  type        = string
  default     = ""
  description = "description"
}


variable "app_name" {}
variable "bucket_name" {}
variable "task_role_arn" {}
