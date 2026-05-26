variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "Región (solo para construir ARN patterns conocidos en plan)."
  type        = string
}

variable "aws_account_id" {
  description = "ID de cuenta (solo para construir ARN patterns conocidos en plan)."
  type        = string
}

variable "secretsmanager_extra_secret_arns" {
  description = "ARNs extra explícitos (opcional). Usar solo valores conocidos en tfvars; evita salidas de otros recursos para no romper plan."
  type        = list(string)
  default     = []
}
