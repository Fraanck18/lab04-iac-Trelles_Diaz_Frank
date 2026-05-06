# CONFIGURACION IAM Role (image_5aa42d.png)
resource "aws_iam_role" "upload_lambda_role" {
  name = "upload-lambda-role-${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}



# CONFIGURACION \nDeps
locals {
  upload_deps = "@aws-sdk/client-s3, busboy, uuid"
}



# RECURSO PRINCIPAL: Lambda Function (image_5aa7c8.png & image_5a3e8d.png)
resource "aws_lambda_function" "upload_lambda" {
  function_name = "upload-lambda-${terraform.workspace}"
  filename      = "${path.module}/../../src/lambda/upload/index.zip"
  role          = aws_iam_role.upload_lambda_role.arn

  # CONFIGURACION \nDeps
  description   = "Deps: ${local.upload_deps}"

  # CONFIGURACION \nRuntime, \nMemory, \nTimeout y \nHandler
  runtime       = "nodejs20.x"
  memory_size   = 256
  timeout       = 30
  handler       = "index.handler"

  # CONFIGURACION \nEnv
  environment {
    variables = {
      S3_BUCKET     = aws_s3_bucket.images.id
      UPLOAD_PREFIX = "uploads/"
    }
  }

  # CONFIGURACION VPC para RÉPLICA en AZ-b 
  vpc_config {
    subnet_ids = [
      aws_subnet.private_az_a.id, 
      aws_subnet.private_az_b.id
    ]
    security_group_ids = [aws_security_group.sg_upload_lambda.id]
  }

  tags = {
    Project = "PROC-IMG-API"
    AZ      = "Multi-AZ"
  }
}



# CONFIGURACION \nIAM
resource "aws_iam_role_policy" "upload_lambda_policy" {
  name = "upload-lambda-permissions"
  role = aws_iam_role.upload_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.images.arn}/uploads/*"
      }
    ]
  })
}



# CONFIGURACION POLITICAS \nIAM 
resource "aws_iam_role_policy_attachment" "upload_basic_exec" {
  role       = aws_iam_role.upload_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "upload_vpc_exec" {
  role       = aws_iam_role.upload_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# CONFIGURACION \nLogs 
resource "aws_cloudwatch_log_group" "upload_lambda_logs" {
  name              = "/aws/lambda/upload-lambda-${terraform.workspace}"
  retention_in_days = 14

  tags = {
    FilePath    = "iac/terraform/upload-lambda.tf"
    Environment = terraform.workspace
  }
}