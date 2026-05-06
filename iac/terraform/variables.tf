# CONFIGURACION REGION Y PROYECTO
variable "region" {
  description = "Region de AWS de despliegue"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre base para los recursos"
  type        = string
  default     = "PROC-IMG-API"
}

#CONFIGURACION DE ENTORNOS 
variable "aws_profiles" {
  type = map(string)
  default = {
    dev  = "tfdev"
    qa   = "tfqa"
    prod = "tfprod"
  }
}

locals {
  aws_profile = var.aws_profiles[terraform.workspace]
}

#PARAMETROS DE RED 
variable "vpc_cidr" {
  description = "Rango de IPs para la VPC"
  type        = string
}

variable "public_subnets" {
  description = "Lista de CIDRs para subredes publicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "Lista de CIDRs para subredes privadas"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

#PARAMETROS DE APLICACION 
variable "retention_in_days" {
  description = "Retencion de logs en CloudWatch"
  type        = number
  default     = 14
}

variable "upload_prefix" {
  description = "Carpeta de origen en S3"
  type        = string
  default     = "uploads/"
}

variable "processed_prefix" {
  description = "Carpeta de destino en S3"
  type        = string
  default     = "processed/"
}