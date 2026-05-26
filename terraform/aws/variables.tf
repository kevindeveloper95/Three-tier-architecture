variable "aws_region" {
  description = "Región de AWS donde desplegar recursos."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Nombre del entorno (dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Nombre del proyecto (etiquetas y nombres de recursos)."
  type        = string
  default     = "ritual-roast"
}

variable "vpc_cidr" {
  description = "CIDR de la VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "ec2_launch_template_instance_type" {
  description = "Tipo de instancia del launch template web (p. ej. t2.micro)."
  type        = string
  default     = "t2.micro"
}

variable "ec2_launch_template_root_volume_gb" {
  description = "Tamaño del disco raíz EBS (gp3) para instancias lanzadas desde el launch template."
  type        = number
  default     = 20
}

variable "ec2_secretsmanager_extra_arns" {
  description = "ARNs extra para GetSecretValue en el rol EC2 (opcional). Usa valores literales conocidos en tfvars; no uses outputs de otros recursos para evitar errores de plan."
  type        = list(string)
  default     = []
}

variable "web_app_asg_min_size" {
  description = "Mínimo de instancias del ASG web."
  type        = number
  default     = 2
}

variable "web_app_asg_max_size" {
  description = "Máximo de instancias del ASG web."
  type        = number
  default     = 2
}

variable "web_app_asg_desired_capacity" {
  description = "Instancias deseadas del ASG web."
  type        = number
  default     = 2
}

variable "web_app_asg_health_check_grace_period" {
  description = "Segundos antes de que el ALB evalúe salud tras lanzar instancia (user-data / arranque)."
  type        = number
  default     = 300
}

variable "web_app_asg_enable" {
  description = "Si es false, no se crea el Auto Scaling Group."
  type        = bool
  default     = true
}

variable "s3_bucket_name" {
  description = "Nombre del bucket S3 (debe ser globalmente único). Si se deja vacío, se genera con project/environment/account/region."
  type        = string
  default     = ""
}

variable "s3_bucket_versioning_enabled" {
  description = "Activa/desactiva versionamiento en el bucket."
  type        = bool
  default     = true
}

variable "s3_bucket_force_destroy" {
  description = "Si true, permite destruir el bucket aunque tenga objetos (Terraform vacía el bucket en destroy)."
  type        = bool
  default     = true
}

variable "rds_mysql_database_name" {
  type        = string
  default     = "ritual_roast"
  description = "Nombre de la base MySQL (db_name en RDS)."
}

variable "rds_mysql_username" {
  type        = string
  default     = "ritual_roast_admin"
  description = "Usuario maestro MySQL."
}

variable "rds_mysql_password" {
  type        = string
  nullable    = true
  default     = null
  sensitive   = true
  description = "Contraseña maestra MySQL (opcional). Si la omites y no activas rds_mysql_enable_secret_rotation, RDS crea el secreto maestro rds!db-* en Secrets Manager. Con rotación activa, RDS usa contraseña generada o este valor y Lambda rota un secreto JSON propio (no rds!db-*)."
}

variable "rds_mysql_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "Clase de instancia MySQL."
}

variable "rds_mysql_allocated_storage" {
  type        = number
  default     = 20
  description = "Almacenamiento asignado MySQL (GB)."
}

variable "rds_mysql_multi_az" {
  type        = bool
  default     = true
  description = "RDS MySQL Multi-AZ (alta disponibilidad; casi duplica coste de instancia)."
}

variable "rds_mysql_enable_secret_rotation" {
  type        = bool
  default     = true
  description = "Si es true, RDS usa contraseña en Terraform (generada o rds_mysql_password), sin secreto maestro rds!db-*. Terraform crea un secreto JSON con engine/host/... rotado por Lambda (SAR en VPC o rds_mysql_secret_rotation_lambda_arn)."
}

variable "rds_mysql_secret_rotation_days" {
  type        = number
  default     = 7
  description = "Días entre rotaciones del secreto JSON cuando rds_mysql_enable_secret_rotation es true."
}

variable "rds_mysql_secret_rotation_lambda_arn" {
  type        = string
  default     = ""
  description = "ARN de Lambda de rotación MySQL ya existente. Vacío: SAR en VPC si rds_mysql_rotation_lambda_deploy_in_vpc, si no la Lambda regional 297356227824 (puede fallar con RDS privado)."
}

variable "rds_mysql_rotation_lambda_deploy_in_vpc" {
  type        = bool
  default     = true
  description = "Con rotación activa y ARN Lambda vacío: despliega SecretsManagerRDSMySQLRotationSingleUser en subnets de datos (requiere NAT)."
}

variable "create_mysql_credentials_secret" {
  type        = bool
  default     = true
  description = "Si es true, crea el secreto …-mysql-credentials-… (JSON con engine + host/username/password/dbname/port). La contraseña coincide con RDS. Si además rds_mysql_enable_secret_rotation es true, la rotación Lambda usa este secreto."
}

variable "rds_postgres_database_name" {
  type        = string
  default     = null
  nullable    = true
  description = "Nombre de la base PostgreSQL."
}

variable "rds_postgres_username" {
  type        = string
  default     = null
  nullable    = true
  description = "Usuario maestro PostgreSQL."
}

variable "rds_postgres_password" {
  type        = string
  sensitive   = true
  default     = null
  nullable    = true
  description = "Contraseña maestra PostgreSQL."
}

variable "rds_postgres_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "Clase de instancia PostgreSQL."
}

variable "rds_postgres_allocated_storage" {
  type        = number
  default     = 20
  description = "Almacenamiento asignado PostgreSQL (GB)."
}

variable "ec2_public_key" {
  type        = string
  default     = ""
  description = "Clave pública SSH (OpenSSH) para el key pair de EC2/EKS."
}

variable "eks_cluster_name" {
  type        = string
  default     = ""
  description = "Nombre del cluster EKS."
}

variable "eks_cluster_version" {
  type        = string
  default     = "1.29"
  description = "Versión de Kubernetes para EKS."
}

variable "eks_node_groups" {
  type        = any
  default     = {}
  description = "Mapa de node groups para el módulo EKS (estructura del módulo)."
}

variable "redis_node_type" {
  type        = string
  default     = "cache.t3.micro"
  description = "Tipo de nodo ElastiCache."
}

variable "redis_engine_version" {
  type        = string
  default     = "7.0"
  description = "Versión del motor Redis."
}

variable "redis_num_cache_clusters" {
  type        = number
  default     = 1
  description = "Número de nodos en el cluster Redis."
}

variable "redis_automatic_failover_enabled" {
  type        = bool
  default     = false
  description = "Failover automático Redis (requiere multi-AZ y más de un nodo)."
}

variable "redis_multi_az_enabled" {
  type        = bool
  default     = false
  description = "Multi-AZ para Redis."
}

variable "redis_snapshot_retention_limit" {
  type        = number
  default     = 1
  description = "Días de retención de snapshots Redis."
}

variable "redis_snapshot_window" {
  type        = string
  default     = "03:00-05:00"
  description = "Ventana de backup Redis (UTC)."
}

variable "jobberapp_subdomain" {
  type        = string
  default     = "jobberapp.example.com"
  description = "FQDN para la zona jobberapp (ajusta a tu dominio real)."
}

variable "api_subdomain" {
  type        = string
  default     = "api.jobberapp.example.com"
  description = "FQDN para la zona API."
}
