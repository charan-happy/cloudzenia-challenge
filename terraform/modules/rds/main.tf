resource "aws_db_instance" "main" {
     identifier           = "wordpress-db"
     engine              = "mysql"
     engine_version      = "8.0"
     instance_class      = "db.t4g.micro"
     allocated_storage   = 20
     username            = "wordpress_user"
     password            = var.db_password
     db_name             = "wordpress"
     vpc_security_group_ids = [aws_security_group.rds.id]
     db_subnet_group_name = aws_db_subnet_group.main.name
     backup_retention_period = 7
     skip_final_snapshot = true
   }

   resource "aws_db_subnet_group" "main" {
     name       = "wordpress-db-subnet-group"
     subnet_ids = var.private_subnets
   }

   resource "aws_security_group" "rds" {
     vpc_id = var.vpc_id
     ingress {
       from_port   = 3306
       to_port     = 3306
       protocol    = "tcp"
       security_groups = [var.ecs_sg_id]
     }
     egress {
       from_port   = 0
       to_port     = 0
       protocol    = "-1"
       cidr_blocks = ["0.0.0.0/0"]
     }
   }
