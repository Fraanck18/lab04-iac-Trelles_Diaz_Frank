# CONFIGURACION Main Queue
resource "aws_sqs_queue" "image_queue" {

  # CONFIGURACION \nName
  name = "image-processor-${terraform.workspace}-image-queue"

  # CONFIGURACION \nType
  fifo_queue = false 

  # CONFIGURACION \nVisibility 
  visibility_timeout_seconds = 360

  # CONFIGURACION \nRetention
  message_retention_seconds = 86400

  # CONFIGURACION \nLong polling
  receive_wait_time_seconds = 20

  # CONFIGURACION \nMax receives before DLQ
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.image_queue_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Project     = "PROC-IMG-API"
    Environment = terraform.workspace
  }
}