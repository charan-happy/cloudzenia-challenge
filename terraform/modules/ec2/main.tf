resource "aws_instance" "main" {
  count         = 2
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2
  instance_type = "t3.micro"
  subnet_id     = var.private_subnets[count.index]
  vpc_security_group_ids = [aws_security_group.ec2.id]
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker nginx
    systemctl start docker
    systemctl enable docker
    systemctl start nginx
    systemctl enable nginx
    echo "server {
        listen 80;
        server_name ec2-instance${count.index + 1}.nagacharan.site;
        return 200 'Hello from Instance';
    }
    server {
        listen 80;
        server_name ec2-docker${count.index + 1}.nagacharan.site;
        location / {
            proxy_pass http://localhost:8080;
            proxy_set_header Host \$host;
        }
    }" > /etc/nginx/conf.d/default.conf
    docker run -d -p 8080:80 -e "NGINX_PORT=80" nginx
    systemctl restart nginx
    yum install -y epel-release
    yum install -y certbot python3-certbot-nginx
    certbot --nginx -n --agree-tos -m admin@nagacharan.site -d ec2-instance${count.index + 1}.nagacharan.site -d ec2-docker${count.index + 1}.nagacharan.site
    EOF
  tags = {
    Name = "ec2-${count.index + 1}"
  }
}

resource "aws_eip" "main" {
  count    = 2
  instance = aws_instance.main[count.index].id
  domain = "vpc"
}

resource "aws_security_group" "ec2" {
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [var.alb_sg_id]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [var.alb_sg_id]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [var.alb_sg_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_metric_alarm" "ram" {
  count               = 2
  alarm_name          = "ec2-${count.index + 1}-ram"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RAM utilization for EC2 ${count.index + 1}"
  dimensions = {
    InstanceId = aws_instance.main[count.index].id
  }
}
