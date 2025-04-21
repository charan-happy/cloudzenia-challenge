output "ec2_instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.main[*].id
}
