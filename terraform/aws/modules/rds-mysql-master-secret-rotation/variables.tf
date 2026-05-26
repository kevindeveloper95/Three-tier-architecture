variable "secret_id" {
  description = "ARN o ID del secreto maestro de RDS en Secrets Manager."
  type        = string
}

variable "aws_region" {
  description = "Región (para construir el ARN de la Lambda de rotación gestionada por AWS)."
  type        = string
}

variable "automatically_after_days" {
  description = "Días entre rotaciones automáticas."
  type        = number
  default     = 7
}

variable "rotation_lambda_arn" {
  description = "ARN de la Lambda de rotación. Vacío = plantilla oficial MySQL single-user (cuenta AWS 297356227824)."
  type        = string
  default     = ""
}
