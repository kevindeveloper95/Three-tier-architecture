variable "project_name" {
  description = "Nombre del proyecto (prefijos de recursos)."
  type        = string
}

variable "environment" {
  description = "Entorno (dev, staging, prod)."
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC del target group."
  type        = string
}

variable "target_port" {
  description = "Puerto HTTP de la aplicación (ej. 5000)."
  type        = number
  default     = 5000
}

variable "health_check_path" {
  description = "Ruta del health check."
  type        = string
  default     = "/"
}

variable "tags" {
  description = "Tags adicionales."
  type        = map(string)
  default     = {}
}
