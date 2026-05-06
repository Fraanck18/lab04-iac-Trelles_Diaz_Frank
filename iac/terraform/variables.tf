variable "aws_region" {
    description = "Region de AWS de despliegue"
    type        = string
    default     = "us-east-1"
}

variable "aws_profiles" {
  type = map(string)
  default = {
    dev  = "tfdev"
    qa   = "tfqa"
    prod = "tfprod"
  }
}

# DEFINIMOS PARAMETROS
locals {
  aws_profile = var.aws_profiles[terraform.workspace]
}
