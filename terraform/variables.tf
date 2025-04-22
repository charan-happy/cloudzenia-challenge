variable "hosted_zone_id" {
  description = "Route 53 Hosted Zone ID for nagacharan.site"
  type        = string
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}
