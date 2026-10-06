# Pasarela OT de la planta Maipo Sur (nivel 3.5 del modelo Purdue).
# Hospeda el lector de cloro y es el único equipo que puede hablarle al PLC.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "vpc_id" {
  type = string
}

variable "subred_dmz_id" {
  type = string
}

variable "ami_pasarela" {
  type = string
}

resource "aws_security_group" "pasarela_ot" {
  name   = "pasarela-ot-maipo-sur"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.20.0.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "pasarela_ot" {
  ami                    = var.ami_pasarela
  instance_type          = "t3.micro"
  subnet_id              = var.subred_dmz_id
  vpc_security_group_ids = [aws_security_group.pasarela_ot.id]

  tags = {
    Name   = "pasarela-ot-maipo-sur"
    Planta = "Maipo Sur"
  }
}
