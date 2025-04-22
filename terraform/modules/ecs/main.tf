resource "aws_ecs_cluster" "main" {
  name = "cloudzenia-ecs"
}

resource "aws_ecs_task_definition" "wordpress" {
  family                   = "wordpress"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  container_definitions = jsonencode([{
    name  = "wordpress"
    image = "wordpress:latest"
    essential = true
    portMappings = [{ containerPort = 80, hostPort = 80 }]
    environment = [
      { name = "WORDPRESS_DB_HOST", value = var.rds_endpoint },
      { name = "WORDPRESS_DB_USER", value = "wordpress_user" },
      { name = "WORDPRESS_DB_NAME", value = "wordpress" }
    ]
    secrets = [
      { name = "WORDPRESS_DB_PASSWORD", valueFrom = var.db_password_secret_arn }
    ]
  }])
}

resource "aws_ecs_service" "wordpress" {
  name            = "wordpress-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.wordpress.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.private_subnets
    security_groups = [var.ecs_sg_id]
  }
  load_balancer {
    target_group_arn = var.wordpress_target_group_arn
    container_name   = "wordpress"
    container_port   = 80
  }
}

resource "aws_ecs_task_definition" "microservice" {
  family                   = "microservice"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  container_definitions = jsonencode([{
    name  = "microservice"
    image = "${var.ecr_repository_url}:latest"
    essential = true
    portMappings = [{ containerPort = 3000, hostPort = 3000 }]
  }])
}

resource "aws_ecs_service" "microservice" {
  name            = "microservice-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.microservice.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.private_subnets
    security_groups = [var.ecs_sg_id]
  }
  load_balancer {
    target_group_arn = var.microservice_target_group_arn
    container_name   = "microservice"
    container_port   = 3000
  }
}

resource "aws_appautoscaling_target" "wordpress" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.wordpress.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "wordpress_cpu" {
  name               = "wordpress-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.wordpress.resource_id
  scalable_dimension = aws_appautoscaling_target.wordpress.scalable_dimension
  service_namespace  = aws_appautoscaling_target.wordpress.service_namespace
  target_tracking_scaling_policy_configuration {
    target_value       = 70
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_iam_role" "ecs_execution" {
  name = "ecs_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name = "ecs_task_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "ecs_task_secrets" {
  name = "ecs_task_secrets"
  role = aws_iam_role.ecs_task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Resource = var.db_password_secret_arn
    }]
  })
}