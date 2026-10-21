variable "project_name" {
  description = "Name used to identify Project 1 AWS resources"
  type        = string
  default     = "project1"
}

variable "aws_region" {
  description = "AWS region where Project 1 is deployed"
  type        = string
  default     = "us-east-1"
}

variable "app_port" {
  description = "Port used by the Node.js application"
  type        = number
  default     = 3000
}

variable "db_port" {
  description = "Port used by PostgreSQL"
  type        = number
  default     = 5432
}

variable "instance_type" {
  description = "EC2 instance type used by the application servers"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Minimum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "Normal desired number of EC2 application servers"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "db_instance_class" {
  description = "RDS PostgreSQL instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "vpc_cidr" {
  description = "CIDR block for the Project 1 VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone_1" {
  description = "First Availability Zone for Project 1"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone_2" {
  description = "Second Availability Zone for Project 1"
  type        = string
  default     = "us-east-1b"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for Public Subnet 1 in us-east-1a"
  type        = string
  default     = "10.0.0.0/20"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for Public Subnet 2 in us-east-1b"
  type        = string
  default     = "10.0.16.0/20"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for Private Subnet 1 in us-east-1a"
  type        = string
  default     = "10.0.128.0/20"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for Private Subnet 2 in us-east-1b"
  type        = string
  default     = "10.0.144.0/20"
}

variable "ami_id" {
  description = "AMI ID for the Project 1 application servers"
  type        = string
  default     = "ami-0c49b7a098a9d021d"
}


