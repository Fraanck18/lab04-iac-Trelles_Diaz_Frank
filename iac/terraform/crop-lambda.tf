# CONFIGURACION IAM Role 
resource "aws_iam_role" "crop_lambda_role" {
  name = "crop-lambda-role-${terraform.workspace}"

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
  crop_deps = "@aws-sdk/client-s3, sharp 0.33"
}



# CONFIGURACION Lambda Function Y RÉPLICA EN AZ-b
resource "aws_lambda_function" "crop_lambda" {
  function_name = "crop-lambda-${terraform.workspace}"
  filename      = "${path.module}/../../src/lambda/procesado/index.zip"
  role          = aws_iam_role.crop_lambda_role.arn

  # CONFIGURACION \nDeps
  description   = "Deps: ${local.crop_deps}"

  # CONFIGURACION \nRuntime, \nMemory, \nTimeout y \nHandler
  runtime       = "nodejs20.x"
  memory_size   = 512
  timeout       = 60
  handler       = "index.handler"

  # CONFIGURACION \nEnv
  environment {
    variables = {
      S3_BUCKET        = aws_s3_bucket.images.id
      PROCESSED_PREFIX = "processed/"

      # CONFIGURACION \nCrops
      CROP_SIZE        = "40x40"
      CROP_FIT         = "cover"

      # CONFIGURACION \nOutput
      CROP_FORMAT      = "png"
      CROP_MASK        = "svg-circle"
      CROP_TRANSPARENT = "true"
    }
  }

  # CONFIGURACION VPC para RÉPLICA en AZ-a y AZ-b
  vpc_config {
    subnet_ids = [
      aws_subnet.private_az_a.id, 
      aws_subnet.private_az_b.id
    ]
    security_group_ids = [aws_security_group.sg_crop_lambda.id]
  }

  tags = {
    Project = "PROC-IMG-API"
    HA      = "Replica-AZ-b"
  }
}



# CONFIGURACION \nIAM
resource "aws_iam_role_policy" "crop_lambda_policy" {
  name = "crop-lambda-permissions"
  role = aws_iam_role.crop_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.images.arn}/uploads/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.images.arn}/processed/*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = aws_sqs_queue.image_queue.arn
      }
    ]
  })
}



# CONFIGURACION POLITICAS \nIAM 
resource "aws_iam_role_policy_attachment" "crop_basic_exec" {
  role       = aws_iam_role.crop_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "crop_vpc_exec" {
  role       = aws_iam_role.crop_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}



# CONFIGURACION \nSQS 
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.image_queue.arn
  function_name    = aws_lambda_function.crop_lambda.arn
  batch_size                         = 5
  function_response_types            = ["ReportBatchItemFailures"]
  enabled                            = true
}



# CONFIGURACION \nLogs
resource "aws_cloudwatch_log_group" "crop_lambda_logs" {
  name              = "/aws/lambda/crop-lambda-${terraform.workspace}"
  retention_in_days = 14

  tags = {
    FilePath    = "iac/terraform/crop-lambda.tf"
    Environment = terraform.workspace
  }
}