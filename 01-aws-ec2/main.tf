
# VARIABLES
variable "aws_access_key" {}
variable "aws_secret_key" {}


# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# NETWORK
#This uses the default VPC.  It WILL NOT delete it on destroy.
resource "aws_default_vpc" "default" {

}

# RESOURCES
resource "aws_security_group" "nginx-sg" {
  name        = "nginx_demo"
  description = "Allow ports for nginx demo"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami                    = "ami-06eecef118bbf9259"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  tags = {
    Name = "web-server"
  }
  user_data = <<-EOF
               #! bin/bash
               sudo amazon-linux-extras install epel -y
               sudo yum update
               sudo yum install nginx -y
               sudo service nginx start
               EOF
}