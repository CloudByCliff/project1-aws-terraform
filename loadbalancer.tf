
# ==================================================
# AWS PROJECT 1 - APPLICATION LOAD BALANCER
# HTTP to HTTPS Redirect
# ==================================================

# --------------------------------------------------
# 1. APPLICATION LOAD BALANCER
# --------------------------------------------------

resource "aws_lb" "project1" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  ip_address_type = "ipv4"

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# --------------------------------------------------
# 2. APPLICATION TARGET GROUP
# Sends traffic to our Node.js EC2 servers
# --------------------------------------------------

resource "aws_lb_target_group" "app" {
  name        = "${var.project_name}-app-tg"
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.project1.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/health"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

# --------------------------------------------------
# 3. HTTP LISTENER - PORT 80
# Automatically redirect visitors to HTTPS
# --------------------------------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.project1.arn
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

# --------------------------------------------------
# HTTPS LISTENER - PORT 443
# Already managed separately in https.tf
# Do not duplicate it here.
# --------------------------------------------------
