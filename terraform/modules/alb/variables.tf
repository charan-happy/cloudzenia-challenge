variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "hosted_zone_id" {
  description = "Route 53 Hosted Zone ID for nagacharan.site"
  type        = string
}
