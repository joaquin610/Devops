terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.56.0"
    }
  }
  required_version = ">= 1.8.5"
}

variable "aws_access_key" {
  description = "AWS access key"
}

variable "aws_secret_key" {
  description = "AWS secret key"
}

variable "aws_session_token" {
  description = "AWS session token"
}

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

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Subnet 1
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Subnet 1"
  }
}

# Subnet 2
resource "aws_subnet" "subnet3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Subnet 3"
  }
}

# Associate Route Table with Subnets
resource "aws_route_table_association" "subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet3" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.public.id
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

# Application Load Balancer (ALB)
resource "aws_lb" "alb" {
  name               = "ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet3.id]
  
  tags = {
    Name = "ecs-alb"
  }
}

# ALB Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ALB Target Group
resource "aws_lb_target_group" "app" {
  name     = "ecs-tg"  # Cambiar el nombre para evitar conflicto
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"  # Tipo de target actualizado

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "ecs-tg"
  }
}

# ECS Service updated to include ALB
resource "aws_ecs_service" "service" {
  count            = 4
  name             = element(["BE_Orders_Service", "BE_Shipping_Service", "BE_Products_Service", "BE_Payments_Service"], count.index)
  cluster          = aws_ecs_cluster.main.id
  task_definition  = aws_ecs_task_definition.task.arn
  desired_count    = 1
  launch_type      = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.subnet1.id, aws_subnet.subnet3.id]
    security_groups = [aws_security_group.allow_http.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = 80
  }

  force_new_deployment = true
  tags = {
    Name   = element(["BE_Orders_Service", "BE_Shipping_Service", "BE_Products_Service", "BE_Payments_Service"], count.index)
    Origin = "Terraform"
  }
}

# Key Pair
# resource "aws_key_pair" "deployer_key" {
#   key_name   = "deployer-key"
#   public_key = var.public_key
#   tags = {
#     Name = "Deployer Key Pair"
#   }
#   lifecycle {
#     create_before_destroy = true
#     ignore_changes        = [public_key]
#   }
# }

# S3 Bucket
resource "aws_s3_bucket" "FE_react" {
  bucket = "fe-react-bucket"
  acl    = "private"
  tags = {
    Name = "FE_react"
  }
}

# resource "aws_s3_bucket_public_access_block" "FE_react" {
#   bucket = aws_s3_bucket.FE_react.id

#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }

resource "aws_ecr_repository" "orders_repo" {
  name = "orders-service-repo"
  tags = {
    Name = "Orders Service Repo"
  }
}

resource "aws_ecr_repository" "shipping_repo" {
  name = "shipping-service-repo"
  tags = {
    Name = "Shipping Service Repo"
  }
}

resource "aws_ecr_repository" "products_repo" {
  name = "products-service-repo"
  tags = {
    Name = "Products Service Repo"
  }
}

resource "aws_ecr_repository" "payments_repo" {
  name = "payments-service-repo"
  tags = {
    Name = "Payments Service Repo"
  }
}
