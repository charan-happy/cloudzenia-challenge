variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "ecs_sg_id" {
  description = "Security group ID of the ECS service"
  type        = string
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
}
