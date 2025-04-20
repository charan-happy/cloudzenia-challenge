output "alb_sg_id" {
  description = "Security group ID of the ALB"
  value       = aws_security_group.alb.id
}

output "wordpress_target_group_arn" {
  description = "ARN of the WordPress target group"
  value       = aws_lb_target_group.wordpress.arn
}

output "microservice_target_group_arn" {
  description = "ARN of the microservice target group"
  value       = aws_lb_target_group.microservice.arn
}