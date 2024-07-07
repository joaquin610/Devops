# terraform {
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       version = "5.56.0"
#     }
#   }
#   required_version = ">= 1.8.5"
# }


# provider "aws" {
#   access_key = "ASIA2NBKA2BDGRZIYDEO"
#   secret_key = "xFdIKOAPeTJsG0btQUH2xpa3PyFttCULy/ovJ8Jf"
#   token      = "IQoJb3JpZ2luX2VjEJf//////////wEaCXVzLXdlc3QtMiJIMEYCIQDXnraYVgAB0UGcNCi23r2kxNAWQANctXDetFaeOZ4MHAIhAKGp986Z4YHWlADrIW1tw6PhR8VwQZaIh+hgVANoGRVBKrMCCFAQABoMNzE1MjAwMTg4NDg2Igyf+eR5HeeQpkPyerYqkAJL2UMcPXQCPt/JXu7QOd+4BvdskSaMRM0q7H6KW1kI20ZOTziG4IhUA/wTt6GEkBGXgz6rCt2vv7YwE1KtjYG7j3rTzbToYBzMKPiPGZJwtJJauYWT0HR99jPNYQiAuPMslFrIxpUSTdzaKVlPhY2meJI1RBwNE/aOCR87KVh5MxFB2xvZOSMYZiCOpN/EHEIXkLfLCbeXMGT0w45yNb5aCmaRuejr/9mOJENPWS9aBmx0FoMo+n04KJzym2sb7+BbhPDtQv2knB7pYW0JN9a0SPiNWnaofEu6RwwXVLj57i4oybHAC2xxpYgGkqCcybgrsOgmbd+wd/rXxI7MOudRTg+wv7KGc4l018M646EjYzCFzoe0BjqcASQIcAaWkzXRCunHubnNNgJfiureU2+jHujYQYb0TrrKzoXGda/05bSc/xQpPzVQeMn5I3wW6lLhUEZd5bsSYkHwEy5ipRLxfcgr/IistoT/5WVp+R3M0sxMF95t3fa5Jx21Ie7JKUs6eEHxS+yLQUjarXx7z7i4sJXvSFpmlc0wtyM8xvopuS0Tx98NM1znMuesFAV7DRdY2YtLhQ=="
#   region  = "us-east-1"
# }

# # VPC
# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     Name = "main VPC"
#   }
# }

# # Subnet
# resource "aws_subnet" "subnet1" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.1.0/24"
#   availability_zone = "us-east-1a"
#   tags = {
#     Name = "Subnet 1"
#   }
# }

# # Security Group
# resource "aws_security_group" "allow_http" {
#   vpc_id = aws_vpc.main.id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "Allow HTTP Security Group"
#   }
# }

# # Key Pair
# resource "aws_key_pair" "deployer_key" {
#   key_name   = "deployer-key"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5KTCB/3CPgtaNOFCyfmGy5SKmykLhNEYs5WygYCyt4bY4E+/r4h86/dpACYHgK2lkTAn32jkh6j9AcwAGwTfzVnX1wdY8Qw93LyGyN2is3x0kdZh0zpVbL0mqs2T8K4LO/1Dm3td9Gj/Lt/MtCP/ww40p4u7ia1xQDbYvSt45fiv1a83UfgCMJASzxI4CXl0CuL5QNq3n5L3binVa4m4cnxz5+6dleaKPE91iV1RgVKs1zG08Tc3VszAWQ9DZ/p8d7v178DRLiIiZRZCM64V8q4vHxfVlWjc6Ap91X+zd2eA5AADq9dSrSokTDWq8kHkGfD8Bg7mW1sIeQ7PRX9uz joaquin banchero@DESKTOP-4I9PHVS"
#   tags = {
#     Name = "Deployer Key Pair"
#   }
# }

# # Resource Block
# resource "aws_instance" "service_cluster" {
#   count                  = 5
#   ami                    = "ami-0be2609ba883822ec" # Amazon Linux in us-east-1, update as per your region
#   instance_type          = "t2.micro"
#   key_name               = aws_key_pair.deployer_key.key_name
#   subnet_id              = aws_subnet.subnet1.id
#   vpc_security_group_ids = [aws_security_group.allow_http.id]

#   tags = {
#     Name   = element(["BE Orders Service", "BE Shipping Service", "BE Products Service", "BE Payments Service", "FE React"], count.index)
#     Origin = "Terraform"
#   }
# }


//new
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.56.0"
    }
  }
  required_version = ">= 1.8.5"
}

provider "aws" {
  access_key = "ASIA2NBKA2BDHIWG6U6K"
  secret_key = "8DRPJ0WFLK0gAjcbNDDeUq327GfU4+PxSMri9a6K"
  token      = "IQoJb3JpZ2luX2VjECoaCXVzLXdlc3QtMiJIMEYCIQDk58qFtBa/F+HrDkYPl2o5iyeWZXZ7HBKp6XfzS3hd4wIhAIV62zR9ZuZ3x+wqEJYvZrWwdX9vj98vUMqGoAOlzLRgKrwCCOP//////////wEQABoMNzE1MjAwMTg4NDg2IgwBVcpkLAePWN+ab7IqkAJ9gZ9XBf3GzEl4g/2LDQvylBH8p8zpDV5nfy05hm0tPSWaB6YTXQgdBrSSRFj6c1cqYIjjRwWjtXets1su2VDFkMMViyaNtDyhYUWJmnb4rFqe1LCc6AIG1LVoc5TcBAwE9voISgLtj64IHoUiDSQ36H3N3l2LPPOoWKwJs7SEQwJcLu7IZ7gOfbJwG1mu+DIPgeNF5bSE5i0j2/cR4EYxSIhRsTkw0oCs9kuTk737eZa2EyUVTDVMtJvYqQAu1IMVAOGplARiXgTqUKxcH3PdfgXyPjWu5Tniy5xK8x0u8e5J6YT09ivnq4k6R0i2Zi6uGc4i4hCk2KUVSGvmK6HBtRt91FxVOv2XkFPDXr4xqzCW3Ke0BjqcAc1jyJsUkWzKisjgQaHVZIHkpHvzK+KkRBE/oE/2kqqXkQaPiTSzGnSbFOKbf/hQ8EC5fyNY9VKFIcNA/RCXOMQcg/h7BoWrMv0pDSVnwnJ2xozseNE7ZnHUcrwRGZV5KapdkdTpyDuYb10Vis3CrCpbVKoJN3onzgwfpVKbU18FaYfpB6+MhwUM+0FYndox2tsGw50PKQy4EjdQDg=="
  region    = "us-east-1"
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
  count            = 5
  name             = element(["BE_Orders_Service", "BE_Shipping_Service", "BE_Products_Service", "BE_Payments_Service", "FE_React"], count.index)
  cluster          = aws_ecs_cluster.main.id
  task_definition  = aws_ecs_task_definition.task.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.subnet1.id]
    security_groups = [aws_security_group.allow_http.id]
    assign_public_ip = true
  }
  tags = {
    Name   = element(["BE_Orders_Service", "BE_Shipping_Service", "BE_Products_Service", "BE_Payments_Service", "FE_React"], count.index)
    Origin = "Terraform"
  }
}

# Key Pair
resource "aws_key_pair" "deployer_key" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5KTCB/3CPgtaNOFCyfmGy5SKmykLhNEYs5WygYCyt4bY4E+/r4h86/dpACYHgK2lkTAn32jkh6j9AcwAGwTfzVnX1wdY8Qw93LyGyN2is3x0kdZh0zpVbL0mqs2T8K4LO/1Dm3td9Gj/Lt/MtCP/ww40p4u7ia1xQDbYvSt45fiv1a83UfgCMJASzxI4CXl0CuL5QNq3n5L3binVa4m4cnxz5+6dleaKPE91iV1RgVKs1zG08Tc3VszAWQ9DZ/p8d7v178DRLiIiZRZCM64V8q4vHxfVlWjc6Ap91X+zd2eA5AADq9dSrSokTDWq8kHkGfD8Bg7mW1sIeQ7PRX9uz joaquin banchero@DESKTOP-4I9PHVS"
  tags = {
    Name = "Deployer Key Pair"
  }
}
