variable "project_name" {
  description = "Nombre del proyecto (prefijos de recursos)."
  type        = string
}

variable "environment" {
  description = "Entorno (dev, staging, prod)."
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs de al menos dos subnets públicas en distintas AZ para el ALB."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups del ALB (normalmente el SG dedicado al balanceador)."
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN del target group al que el listener HTTP reenvía el tráfico."
  type        = string
}

variable "listener_http_port" {
  description = "Puerto del listener HTTP del ALB (frente a Internet)."
  type        = number
  default     = 80
}

variable "tags" {
  description = "Tags adicionales."
  type        = map(string)
  default     = {}
}
