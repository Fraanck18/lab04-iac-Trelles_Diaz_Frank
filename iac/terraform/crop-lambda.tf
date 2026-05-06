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


# CONFIGURACION \nRuntime, \nMemory, \nTimeout y \nHandler
  runtime     = "nodejs20.x"
  memory_size = 512
  timeout     = 60
  handler     = "index.handler"



# CONFIGURACION \nDeps
locals {
  crop_deps = "@aws-sdk/client-s3, sharp 0.33"
}



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


# CONFIGURACION \nIAM: S3 y SQS Permissions
resource "aws_iam_role_policy" "crop_lambda_policy" {
  name = "crop-lambda-permissions"
  role = aws_iam_role.crop_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # s3:GetObject on uploads/
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.images.arn}/uploads/*"
      },
      # s3:PutObject on processed/
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.images.arn}/processed/*"
      },
      # nSQS: Receive, Delete, Attributes, Visibility
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



# CONFIGURACION \nSQS
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.image_queue.arn
  function_name    = aws_lambda_function.crop_lambda.arn
  
  batch_size = 10
  enabled    = true
}



# CONFIGURACION \nLogs
resource "aws_cloudwatch_log_group" "crop_lambda_logs" {
  name              = "/aws/lambda/crop-lambda-${terraform.workspace}"

  # CONFIGURACION \nRetention: 14 days
  retention_in_days = 14

  tags = {
    FilePath    = "iac/terraform/crop-lambda.tf"
    Environment = terraform.workspace
  }
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