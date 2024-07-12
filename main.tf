terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.56.0"
    }
  }
  required_version = ">= 1.8.5"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_session_token" {}
variable "public_key" {}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
  region     = "us-east-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main VPC"
  }
}

# Subnet
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Subnet 1"
  }
}

# Security Group
resource "aws_security_group" "allow_http" {
  vpc_id = aws_vpc.main.id

  ingress {
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
    Name = "Allow HTTP Security Group"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "main-ecs-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = "service"
  container_definitions    = jsonencode([
    {
      name  = "app"
      image = "amazon/amazon-ecs-sample"
      memory = 256
      cpu    = 256
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
}

# ECS Service
resource "aws_ecs_service" "service" {
  count            = 4
  name             = element(["BE_Orders_Service", "BE_Shipping_Service", "BE_Products_Service", "BE_Payments_Service"], count.index)
  cluster          = aws_ecs_cluster.main.id
  task_definition  = aws_ecs_task_definition.task.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.subnet1.id]
    security_groups = [aws_security_group.allow_http.id]
    assign_public_ip = true
  }
  force_new_deployment = true
  tags = {
    Name   = element(["BE_Orders_Service", "BE_Shipping_Service", "BE_Products_Service", "BE_Payments_Service"], count.index)
    Origin = "Terraform"
  }
}

# Key Pair
resource "aws_key_pair" "deployer_key" {
  key_name   = "deployer-key"
  public_key = var.public_key
  tags = {
    Name = "Deployer Key Pair"
  }
  lifecycle {
    prevent_destroy = true
  }
}

# S3 Bucket
resource "aws_s3_bucket" "FE_react" {
  bucket = "fe-react-bucket"
  acl    = "private"
  tags = {
    Name = "FE_react"
  }
}
