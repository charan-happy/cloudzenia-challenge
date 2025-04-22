resource "aws_lb" "main" {
  name               = "cloudzenia-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnets
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.main.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
  }
}

resource "aws_lb_listener_rule" "microservice" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.microservice.arn
  }
  condition {
    host_header {
      values = ["microservice.nagacharan.site"]
    }
  }
}

resource "aws_lb_listener_rule" "ec2_instance1" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 101
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_instance1.arn
  }
  condition {
    host_header {
      values = ["ec2-instance1.nagacharan.site"]
    }
  }
}

resource "aws_lb_listener_rule" "ec2_docker1" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 102
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_docker1.arn
  }
  condition {
    host_header {
      values = ["ec2-docker1.nagacharan.site"]
    }
  }
}

resource "aws_lb_listener_rule" "ec2_instance2" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 103
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_instance2.arn
  }
  condition {
    host_header {
      values = ["ec2-instance2.nagacharan.site"]
    }
  }
}

resource "aws_lb_listener_rule" "ec2_docker2" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 104
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_docker2.arn
  }
  condition {
    host_header {
      values = ["ec2-docker2.nagacharan.site"]
    }
  }
}

resource "aws_lb_target_group" "wordpress" {
  name        = "wordpress-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_target_group" "microservice" {
  name        = "microservice-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_target_group" "ec2_instance1" {
  name        = "ec2-instance1-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
}

resource "aws_lb_target_group" "ec2_docker1" {
  name        = "ec2-docker1-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
}

resource "aws_lb_target_group" "ec2_instance2" {
  name        = "ec2-instance2-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
}

resource "aws_lb_target_group" "ec2_docker2" {
  name        = "ec2-docker2-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
}

resource "aws_security_group" "alb" {
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_acm_certificate" "main" {
  domain_name       = "*.nagacharan.site"
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_route53_record" "wordpress" {
  zone_id = var.hosted_zone_id
  name    = "wordpress.nagacharan.site"
  type    = "A"
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "microservice" {
  zone_id = var.hosted_zone_id
  name    = "microservice.nagacharan.site"
  type    = "A"
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ec2_instance1" {
  zone_id = var.hosted_zone_id
  name    = "ec2-instance1.nagacharan.site"
  type    = "A"
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ec2_docker1" {
  zone_id = var.hosted_zone_id
  name    = "ec2-docker1.nagacharan.site"
  type    = "A"
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ec2_instance2" {
  zone_id = var.hosted_zone_id
  name    = "ec2-instance2.nagacharan.site"
  type    = "A"
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ec2_docker2" {
  zone_id = var.hosted_zone_id
  name    = "ec2-docker2.nagacharan.site"
  type    = "A"
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ec2_alb_docker" {
  zone_id = var.hosted_zone_id
  name    = "ec2-alb-docker.nagacharan.site"
  type    = "A"
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ec2_alb_instance" {
  zone_id = var.hosted_zone_id
  name    = "ec2-alb-instance.nagacharan.site"
  type    = "A"
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
