resource "aws_db_subnet_group" "project1" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Private subnets for Project 1 PostgreSQL database"

  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}

resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-postgres-db"

  engine         = "postgres"
  engine_version = "18.3"

  instance_class = var.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 1000
  storage_type          = "gp2"
  storage_encrypted     = true

  db_name  = "project1db"
  username = "project1admin"

  port = var.db_port

  db_subnet_group_name   = aws_db_subnet_group.project1.name
  vpc_security_group_ids = [aws_security_group.db.id]

  publicly_accessible = false
  multi_az            = false

  iam_database_authentication_enabled = false
  deletion_protection                 = true
  performance_insights_enabled        = true
  copy_tags_to_snapshot               = true
  skip_final_snapshot                 = true
}