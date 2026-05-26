variable "project_name" {
  description = "Nombre del proyecto (prefijos de recursos)."
  type        = string
}

variable "environment" {
  description = "Entorno (dev, staging, prod)."
  type        = string
}

variable "aws_region" {
  description = "Región de despliegue (debe coincidir con el provider)."
  type        = string
}

variable "lambda_security_group_id" {
  description = "ID del security group de la Lambda en VPC. Suele ser el mismo que el de RDS MySQL (mysql-sg) para coincidir con diagramas que reutilizan el SG de la base."
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnets privadas con ruta a NAT (Lambda llama a Secrets Manager y a RDS)."
  type        = list(string)
}

variable "tags" {
  description = "Etiquetas adicionales para el stack."
  type        = map(string)
  default     = {}
}
