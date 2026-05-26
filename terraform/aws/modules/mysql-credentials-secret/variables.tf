variable "project_name" {
  description = "Nombre del proyecto."
  type        = string
}

variable "environment" {
  description = "Entorno."
  type        = string
}

variable "secret_name_slug" {
  description = "Fragmento del nombre del secreto: {project}-{slug}-{environment}."
  type        = string
  default     = "mysql-credentials"
}

variable "db_host" {
  description = "Hostname RDS (db_instance_address)."
  type        = string
}

variable "db_port" {
  description = "Puerto MySQL."
  type        = number
  default     = 3306
}

variable "db_database" {
  description = "Nombre de la base (db_name)."
  type        = string
}

variable "db_username" {
  description = "Usuario maestro."
  type        = string
}

variable "db_password" {
  description = "Contraseña maestro (debe coincidir con la instancia RDS)."
  type        = string
  sensitive   = true
}

variable "recovery_window_in_days" {
  description = "Ventana de recuperación al borrar el secreto (0 = borrado inmediato en dev)."
  type        = number
  default     = 0
}

variable "tags" {
  description = "Tags adicionales."
  type        = map(string)
  default     = {}
}
