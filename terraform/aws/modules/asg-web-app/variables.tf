variable "project_name" {
  description = "Nombre del proyecto."
  type        = string
}

variable "environment" {
  description = "Entorno."
  type        = string
}

variable "launch_template_id" {
  description = "ID del launch template."
  type        = string
}

variable "launch_template_version" {
  description = "Versión del launch template (número o \"$Latest\")."
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnets privadas webapp (multi-AZ)."
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN del target group del ALB (health checks ELB)."
  type        = string
}

variable "min_size" {
  description = "Mínimo de instancias."
  type        = number
}

variable "max_size" {
  description = "Máximo de instancias."
  type        = number
}

variable "desired_capacity" {
  description = "Capacidad deseada."
  type        = number
}

variable "health_check_grace_period" {
  description = "Segundos antes de evaluar health ELB tras lanzar instancia (user-data / arranque app)."
  type        = number
  default     = 300
}

variable "tags" {
  description = "Etiquetas del ASG."
  type        = map(string)
  default     = {}
}
