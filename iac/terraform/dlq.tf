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

# CONFIGURACION \nCloudWatch alarm
resource "aws_cloudwatch_metric_alarm" "dlq_alarm" {

  alarm_name          = "dlq-messages-alarm-${terraform.workspace}" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "60" 
  statistic           = "Sum"
  threshold           = "0"
  
  # CONFIGURACION \nAction: notify via SNS topic
  alarm_actions       = [aws_sns_topic.dlq_alerts.arn]

  dimensions = {
    QueueName = aws_sqs_queue.image_queue_dlq.name
  }

  alarm_description   = "Mensajes fallidos en la DLQ "
}

# CONFIGURACION trigger alarm 
resource "aws_sns_topic" "dlq_alerts" {
  name = "dlq-messages-alerts-${terraform.workspace}"
}