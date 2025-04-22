resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "cloudzenia-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", "${var.ecs_cluster_name}"],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", "${var.ecs_cluster_name}"]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "ECS Cluster Metrics"
          region  = "ap-south-1"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", "${var.ec2_instance_ids[0]}"],
            ["AWS/EC2", "CPUUtilization", "InstanceId", "${var.ec2_instance_ids[1]}"],
            ["AWS/EC2", "MemoryUtilization", "InstanceId", "${var.ec2_instance_ids[0]}"],
            ["AWS/EC2", "MemoryUtilization", "InstanceId", "${var.ec2_instance_ids[1]}"]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "EC2 Instance Metrics"
          region  = "ap-south-1"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${var.rds_instance_id}"]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "RDS Metrics"
          region  = "ap-south-1"
        }
      }
    ]
  })
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ec2_instance_ids" {
  description = "List of EC2 instance IDs"
  type        = list(string)
}

variable "rds_instance_id" {
  description = "RDS instance identifier"
  type        = string
}
