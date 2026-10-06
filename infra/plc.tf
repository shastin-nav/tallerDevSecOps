# Pasarela OT de la planta Maipo Sur (nivel 3.5 del modelo Purdue).
# Hospeda el lector de cloro y es el único equipo que puede hablarle al PLC.
# Revisado con `trivy config infra/` en el Ejercicio 2 · Fase B (ver ENTREGABLE.md).

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.100.0" # versión exacta, no un rango
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

variable "red_operaciones_cidr" {
  description = "Red del centro de operaciones (HMI de los operadores de turno)"
  type        = string
  default     = "10.20.0.0/24"
}

variable "red_ot_cidr" {
  description = "Red OT donde vive el PLC de dosificación (nivel 1)"
  type        = string
  default     = "10.30.0.0/24"
}

resource "aws_security_group" "pasarela_ot" {
  name        = "pasarela-ot-maipo-sur"
  description = "Pasarela OT Maipo Sur: solo operaciones entra, solo hacia el PLC sale"
  vpc_id      = var.vpc_id

  ingress {
    description = "Lector de cloro, solo desde la red de operaciones"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.red_operaciones_cidr]
  }

  # Antes: salida a 0.0.0.0/0 en todos los puertos (AWS-0104, CRITICAL).
  # Ahora: la pasarela solo puede hablarle a la red OT, y solo por los puertos necesarios.
  egress {
    description = "API HTTPS de la pasarela del PLC en la red OT"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.red_ot_cidr]
  }

  egress {
    description = "Modbus/TCP hacia el PLC de dosificacion en la red OT"
    from_port   = 502
    to_port     = 502
    protocol    = "tcp"
    cidr_blocks = [var.red_ot_cidr]
  }
}

resource "aws_instance" "pasarela_ot" {
  ami                    = var.ami_pasarela
  instance_type          = "t3.micro"
  subnet_id              = var.subred_dmz_id
  vpc_security_group_ids = [aws_security_group.pasarela_ot.id]

  # IMDSv2 obligatorio (AWS-0028)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Disco cifrado (AWS-0131)
  root_block_device {
    encrypted = true
  }

  tags = {
    Name   = "pasarela-ot-maipo-sur"
    Planta = "Maipo Sur"
  }
}
