variable "bucket_name" {
  description = "Nombre del bucket S3 (debe ser globalmente único)."
  type        = string
}

variable "versioning_enabled" {
  description = "Activa/desactiva versionamiento en el bucket."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Si true, permite destruir el bucket aunque tenga objetos."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags adicionales para el bucket."
  type        = map(string)
  default     = {}
}

