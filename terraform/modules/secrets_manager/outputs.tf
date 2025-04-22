output "db_password_secret_arn" {
  description = "ARN of the Secrets Manager secret for the RDS password"
  value       = aws_secretsmanager_secret.db_password.arn
}
