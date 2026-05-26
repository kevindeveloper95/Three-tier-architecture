variable "project_name" {
  type        = string
  description = "Nombre del proyecto."
}

variable "environment" {
  type        = string
  description = "Entorno (dev, staging, prod)."
}

variable "instance_type" {
  type        = string
  description = "Tipo de instancia EC2."
  default     = "t2.micro"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Security groups de la instancia (p. ej. web app)."
}

variable "iam_instance_profile_name" {
  type        = string
  description = "Nombre del instance profile IAM (rol EC2)."
}

variable "user_data_base64" {
  type        = string
  description = "User data en base64 (script de arranque)."
}

variable "root_volume_gb" {
  type        = number
  description = "Tamaño del volumen raíz EBS (GiB)."
  default     = 20
}

variable "tags" {
  type        = map(string)
  description = "Etiquetas para el launch template."
  default     = {}
}
