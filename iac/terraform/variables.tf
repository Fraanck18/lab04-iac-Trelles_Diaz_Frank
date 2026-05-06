variable "aws_region" {
    description = "Region de AWS de despliegue"
    type        = string
    default     = "us-east-1"
}

variable "aws_profiles" {
  type = map(string)
  default = {
    dev  = "tfdev"
    qa   = "tfdev"
    prod = "tfdev"
  }
}

# NECESITAMOS DEFINIR EL PARAMETRO PARA LA ELECCION DEL ENTORNO DE DESPLIEGUE
locals {
  aws_profile = var.aws_profiles[terraform.workspace]
}
