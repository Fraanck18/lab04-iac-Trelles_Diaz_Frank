# CONFIGURACION Dead-Letter Queue
resource "aws_sqs_queue" "image_queue_dlq" {
  # CONFIGURACION \nName
  name = "image-processor-${terraform.workspace}-image-dlq"

  # CONFIGURACION \nRetention
  message_retention_seconds = 1209600

  tags = {
    Project     = "PROC-IMG-API"
    Environment = terraform.workspace
    Type        = "DLQ"
  }
}

# CONFIGURACION \nCloudWatch 
resource "aws_cloudwatch_metric_alarm" "dlq_alarm" {
  alarm_name          = "alarm-sqs-image-processor-${terraform.workspace}-dlq-not-empty"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "60" # 1 minuto
  statistic           = "Sum"
  threshold           = "0" 
  alarm_description   = "Mensajes fallidos en la DLQ de PROC-IMG-API"
  
  dimensions = {
    QueueName = aws_sqs_queue.image_queue_dlq.name
  }

  # ACTIVACION DE ALARMA SNS
  alarm_actions = [aws_sns_topic.alerts.arn]
}