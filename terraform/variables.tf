variable "hosted_zone_id" {
  description = "Route 53 Hosted Zone ID for nagacharan.site"
  type        = string
  value = "Z05135773VBNXAZ3YSQ5W"
  sensitive = true
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
  value = "Iamcharan.123"
}
