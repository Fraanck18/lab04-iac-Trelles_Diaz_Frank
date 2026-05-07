#Requisitos Previos (Prerrequisitos)
Antes de los comandos de Terraform, el usuario debe tener herramientas instaladas:

--> Terraform v1.0.0+ ---> npm install -g terraform-cli

--> AWS CLI configurado con SSO. ---> msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi /qn

--> Node.js & NPM (para empaquetar las lambdas). ---> msiexec.exe /i https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi /qn

--> Zip/PowerShell para crear los paquetes de despliegue. ---> Compress-Archive -Path * -DestinationPath index.zip -Force



#Estructura del Proyecto:

├── iac/terraform/       # Archivos de configuración de Terraform 
├── src/lambda/          # Código fuente de las funciones Lambda
│   ├── upload/          # Lambda para carga de imágenes
│   └── procesado/       # Lambda para procesamiento 
└── terraform.tfvars     # Valores de las variables globales



PASOS PARA PODER EJECUTAR SATISFACTORIAMENTE:
 #CREACION DE RAMAS
 --> terraform workspace new dev
 --> terraform workspace new prod
 --> terraform workspace new qa



#En caso halla error por tiempo de sesion expirado o se requiera ejecutar desde otra rama
aws sso login --profile tfdev    --> iniciar sesion para la rama dev
aws sso login --profile tfqa     --> iniciar sesion para la rama qa
aws sso login --profile tfprod   --> iniciar sesion para la rama prod



 --> terraform workspace select dev #Para seleccionar la rama dev
 --> terraform workspace select qa #Para seleccionar la rama qa
 --> terraform workspace select prod #Para seleccionar la rama prod



 --> terraform init #La primera vez al ejecutar
 --> terraform validate #Verificar concordancia a nivel de codigo
 --> terraform plan #Iniciar planificacion
    --->Ingresar ip y mascara: 10.0.0.0/16
    --->Ingresar "yes"
 #ESPERAR A QUE EL PLAN FUNCIONE
 #MISMO PROCESO PARA EL APPLY
 --> terraform apply #Iniciar planificacion
    --->Ingresar ip y mascara: 10.0.0.0/16
    --->Ingresar "yes"


#IMPORTANTE RECORDAR QUE PARA EJECUTAR EN RAMAS DIFERENTES PRIMERO SE DEBE DE CAMBIAR#
Componentes: API Gateway, AWS Lambda, S3, SQS y VPC con Endpoints de seguridad.



#######-----NECESARIO PARA EJECUTAR-----#######
-> ejecutar --> terraform plan -var-file="terraform.tfvars"  --->#$FORZAMOS LA LECTURA$#

DENTRO DEL ARCHIVO "terraform.tfvars"

retention_in_days = xx
region            = "region-sso"
project_name      = "nombre-proyecto"


vpc_cidr          = "1x.x.x.x/16"


public_subnets    = ["1x.x.x.x/24", "1x.x.x.x/24"]
private_subnets   = ["1x.x.x.x/24", "1x.x.x.x/24"]


upload_prefix     = "uploads/"
processed_prefix  = "processed/"

 


