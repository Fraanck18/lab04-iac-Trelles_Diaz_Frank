# CONFIGURACION S3 - BUCKET
resource "aws_s3_bucket" "images" {
  bucket = "proc-img-api-storage-${terraform.workspace}"

  tags = {
    Name        = "PROC-IMG-API-bucket-${terraform.workspace}"
    Environment = terraform.workspace
    Project     = "PROC-IMG-API"
  }
}



# CONFIGURACION \nStores 
resource "aws_s3_object" "upload_folder" {
  bucket = aws_s3_bucket.images.id
  key    = "upload/" 
}

resource "aws_s3_object" "procesado_folder" {
  bucket = aws_s3_bucket.images.id
  key    = "procesado/" 
}



# CONFIGURACION \nSSE 
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.images.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" 
    }
  }
}



# CONFIGURACION \nVersioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.images.id
  versioning_configuration {
    status = "Enabled" 
  }
}



# CONFIGURACION \nLifecycle
resource "aws_s3_bucket_lifecycle_configuration" "images_lifecycle" {
  bucket = aws_s3_bucket.images.id

  rule {
    id     = "expire-original-images"
    status = "Enabled"
    filter {
      prefix = "upload/" 
    }
    expiration {
      days = 30 
    }
  }



  rule {
    id     = "expire-processed-images"
    status = "Enabled"
    filter {
      prefix = "procesado/" 
    }
    expiration {
      days = 90 
    }
  }
}



# CONFIGURACION \nAccess FULLY PRIVATE
resource "aws_s3_bucket_public_access_block" "images_access" {
  bucket = aws_s3_bucket.images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



# CONFIGURACION \nOn SQS Notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.images.id

  queue {
    queue_arn     = aws_sqs_queue.image_queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "upload/" 
  }

  depends_on = [aws_sqs_queue_policy.image_queue_policy]
}