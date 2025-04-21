variable "hosted_zone_id" {
  description = "Route 53 Hosted Zone ID for nagacharan.site"
  type        = string
  default     = "xyz"
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  default     = "xyz@1"
}
