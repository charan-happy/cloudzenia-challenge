variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "ecs_sg_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "alb_sg_id" {
  description = "Security group ID of the ALB"
  type        = string
}

variable "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  type        = string
}

variable "db_password_secret_arn" {
  description = "ARN of the SecretsManager secret for RDS password"
  type        = string
}

variable "wordpress_target_group_arn" {
  description = "ARN of the ALB target group for WordPress"
  type        = string
}

variable "microservice_target_group_arn" {
  description = "ARN of the ALB target group for microservice"
  type        = string
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository for the microservice"
  type        = string
}