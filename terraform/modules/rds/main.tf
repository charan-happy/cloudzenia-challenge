resource "aws_db_instance" "main" {
     identifier           = "wordpress-db"
     engine              = "mysql"
     engine_version      = "8.0"
     instance_class      = "db.t4g.micro"
     allocated_storage   = 20
     username            = "admin"
     password            = var.db_password
     db_name             = "wordpress"
     vpc_security_group_ids = [var.ecs_sg_id]
     db_subnet_group_name = aws_db_subnet_group.main.name
     backup_retention_period = 7
     skip_final_snapshot = true
   }

   resource "aws_db_subnet_group" "main" {
     name       = "wordpress-db-subnet-group"
     subnet_ids = var.private_subnets
   }

