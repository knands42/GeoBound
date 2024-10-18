# Create a VPC for the RDS instance
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create a subnet within the VPC
resource "aws_subnet" "rds_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

# Create a security group to allow inbound traffic to the RDS instance
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow access from anywhere (be cautious!)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_password" "postgres_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "13.3"
  instance_class       = "db.t3.micro"
  db_name                 = "mozio_db"
  username             = "postgres"
  password             = random_password.postgres_password.result
  parameter_group_name = "default.postgres13"
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
}

# Create a DB subnet group (required for VPC)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.rds_subnet.id]

  tags = {
    Name = "rds-subnet-group"
  }
}

# Lightsail Container Service for Django App
resource "aws_lightsail_container_service" "django_service" {
  name         = "django-app-service"
  power        = "nano" 
  scale        = 1
  is_disabled = false

  tags = {
    Name = "DjangoAppService"
  }
}

# Deployment configuration for Lightsail Container Service
resource "aws_lightsail_container_service_deployment_version" "django_deployment" {
  service_name = aws_lightsail_container_service.django_service.name

  public_endpoint {
    container_name = "django-app"
    container_port           = 8000

      health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout_seconds     = 2
        interval_seconds    = 5
        path                = "/ht"
        success_codes       = "200-499"
      }
  }

  container {
    image           = var.repository_url
    container_name  = "django-app"
    environment     = {
      DB_NAME       = "mozio_db"
      DB_USER       = "postgres"
      DB_PASSWORD   = random_password.postgres_password.result
      DB_HOST       = aws_db_instance.postgres.endpoint
      DB_PORT       = "5432"
    }
  }
}
