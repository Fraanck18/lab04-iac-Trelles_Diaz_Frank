# CONFIGURACION SQS_Interf_Endpoint 
resource "aws_vpc_endpoint" "sqs_interface" {
  vpc_id            = aws_vpc.main.id
  
  # CONFIGURACION \nType 
  vpc_endpoint_type = "Interface"

  # CONFIGURACION \nService
  service_name      = "com.amazonaws.us-east-1.sqs"

  # CONFIGURACION \nPrivate DNS
  private_dns_enabled = true

  # CONFIGURACION \nDeployed 
  subnet_ids = [
    aws_subnet.private_az_a.id,
    aws_subnet.private_az_b.id
  ]

  # CONFIGURACION \nSG
  security_group_ids = [aws_security_group.sg_vpce_sqs.id]

  tags = {
    Name    = "sqs-interface-endpoint"
    Project = "PROC-IMG-API"
  }
}

# SECURITY GROUP 
resource "aws_security_group" "sg_vpce_sqs" {
  name        = "sg-vpce-sqs"
  description = "Security group for SQS Interface Endpoint"
  vpc_id      = aws_vpc.main.id

  # CONFIGURACION \nInbound TCP
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_upload_lambda.id]
  }

  # CONFIGURACION \nInbound TCP
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_crop_lambda.id]
  }

  tags = {
    name = "vpce-sqs-sg-${terraform.workspace}"
  }
}