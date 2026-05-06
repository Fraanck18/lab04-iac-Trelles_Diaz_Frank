# La VPC principal
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "main-vpc-${terraform.workspace}" }
}

# Subredes Privadas (Donde viven tus Lambdas)
resource "aws_subnet" "private_az_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.region}a"
  tags = { Name = "private-a-${terraform.workspace}" }
}

resource "aws_subnet" "private_az_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.region}b"
  tags = { Name = "private-b-${terraform.workspace}" }
}

# Security Group para la Lambda de Carga
resource "aws_security_group" "sg_upload_lambda" {
  name        = "sg_upload_lambda_${terraform.workspace}"
  description = "Seguridad para upload lambda"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group para la Lambda de Procesado
resource "aws_security_group" "sg_crop_lambda" {
  name        = "sg_crop_lambda_${terraform.workspace}"
  description = "Seguridad para crop lambda"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Tablas de Rutas (Requeridas por tus errores de s3_gtw_endp.tf)
resource "aws_route_table" "private_rt_az_a" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "private_rt_az_b" {
  vpc_id = aws_vpc.main.id
}

# SUBREDES PÚBLICAS NAT Gateway/Internet Gateway
resource "aws_subnet" "public_az_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true
  tags = { Name = "public-a-${terraform.workspace}" }
}
resource "aws_subnet" "public_az_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}b"
  map_public_ip_on_launch = true
  tags = { Name = "public-b-${terraform.workspace}" }
}