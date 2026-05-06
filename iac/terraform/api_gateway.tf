# HTTP API BASICO 
resource "aws_apigatewayv2_api" "HTTP-API" {
  name          = "PROC-IMG-API-${terraform.workspace}"
  protocol_type = "HTTP"

  # CONFIGURACION DE \nCors
  cors_configuration {
    allow_origins = ["*"] 
    allow_methods = ["POST", "OPTIONS"] 
    allow_headers = ["content-type", "authorization"]
    max_age       = 300
  }
}


# INTEGRACION \nProtocol format 2.0
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.HTTP-API.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.procesador_imagenes.invoke_arn

  # CONFIGURACION DE \nPayload 
  payload_format_version = "2.0" 
}


# CONFIGURACION DE \nRoute para POST /upload
resource "aws_apigatewayv2_route" "upload_route" {
  api_id    = aws_apigatewayv2_api.HTTP-API.id
  route_key = "POST /upload"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}


# CONFIGURACION DE \nStage 
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.HTTP-API.id
  name        = "$default"
  auto_deploy = true

  # CONFIGURACION DE \nThrottling
  default_route_settings {
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
  }

  # CONFIGURACION DE \nAccess logs para Cloudwatch
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn

    #CONFIGURACION PARA \nFormat CAPA OBSERVABILIDAD
    format = jsonencode({
      requestId = "$context.requestId"
      ip        = "$context.identity.sourceIp"
      status    = "$context.status"
      protocol  = "$context.protocol"
    })
  }
}

# CONFIGURACION DE LOG GROUP 
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/iac/terraform/api-gateway/PROC-IMG-API-${terraform.workspace}"
  retention_in_days = 14 # --> DIAGRAMA MERMAID 
}