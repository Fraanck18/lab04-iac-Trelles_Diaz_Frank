# CONFIGURACION VPC Endpoints - S3 Gateway (image_5958bc.png)
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id       = aws_vpc.main.id

  # CONFIGURACION \nType no ENI
  vpc_endpoint_type = "Gateway"

  # CONFIGURACION \nService
  service_name = "com.amazonaws.us-east-1.s3"

  # CONFIGURACION \nInjected into private subnet route tables
  route_table_ids = [
    aws_route_table.private_rt_az_a.id,
    aws_route_table.private_rt_az_b.id
  ]

  # CONFIGURACION \nPolicy
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = "*"
        Action    = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect    = "Allow"
        Resource  = [
          "${aws_s3_bucket.images.arn}",
          "${aws_s3_bucket.images.arn}/*"
        ]
      }
    ]
  })

  tags = {
    Name        = "s3-gateway-endpoint"
    Project     = "PROC-IMG-API"
    Type        = "Gateway-Free"
    Environment = terraform.workspace
  }
}