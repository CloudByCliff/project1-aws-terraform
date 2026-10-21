
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Allows public HTTP traffic to the Project 1 load balancer"
  vpc_id      = aws_vpc.project1.id

  ingress {
    description = "Public website traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Allows Node.js traffic only from the Project 1 load balancer"
  vpc_id      = aws_vpc.project1.id

  ingress {
    description     = "Node.js traffic from ALB only"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Allows PostgreSQL traffic only from Project 1 web servers"
  vpc_id      = aws_vpc.project1.id

  ingress {
    description     = "PostgreSQL from web servers only"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

resource "aws_security_group" "vpce" {
  name        = "${var.project_name}-vpce-sg"
  description = "Allows HTTPS 443 from Project 1 web servers to VPC endpoints"
  vpc_id      = aws_vpc.project1.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-vpce-sg"
  }
}
