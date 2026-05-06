# CONFIGURACION SQS_Interf_Endpoint 
resource "aws_vpc_endpoint" "sqs_interface" {
  vpc_id              = aws_vpc.main.id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${var.region}.sqs"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private_az_a.id,
    aws_subnet.private_az_b.id
  ]

  security_group_ids = [aws_security_group.sg_vpce_sqs.id]

  tags = {
    Name    = "sqs-interface-endpoint-${terraform.workspace}"
    Project = var.project_name
  }
}



# SECURITY GROUP 
resource "aws_security_group" "sg_vpce_sqs" {
  name        = "vpce-sqs-sg-${terraform.workspace}"
  description = "Security group for SQS Interface Endpoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_upload_lambda.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_crop_lambda.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpce-sqs-sg-${terraform.workspace}"
  }
}