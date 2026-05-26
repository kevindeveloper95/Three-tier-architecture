variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "jobber-auth"
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "jobberadmin"
}

variable "manage_master_user_password" {
  description = "Si es true, RDS crea el secreto maestro rds!db-* (no usar junto con master_password)."
  type        = bool
  default     = false
}

variable "master_password" {
  description = "Contraseña maestra en RDS. Obligatoria si manage_master_user_password es false (p. ej. rotación Lambda con secreto JSON propio)."
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "instance_class" {
  description = "Instance class for RDS MySQL (e.g., db.t3.micro)"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Habilitar despliegue Multi-AZ (réplica sincrónica en otra AZ; mayor disponibilidad y coste)."
  type        = bool
  default     = false
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
}

variable "mysql_security_group_id" {
  description = "ID of the MySQL security group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
