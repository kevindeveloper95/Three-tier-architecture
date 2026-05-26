# Resuelve la última 8.0.x de la región (evita ambigüedad con version = "8.0" solo).
data "aws_rds_engine_version" "mysql" {
  engine  = "mysql"
  version = "8.0"
  latest  = true
}

resource "aws_db_instance" "mysql" {
  identifier = "${var.project_name}-mysql-${var.environment}"

  engine         = "mysql"
  engine_version = data.aws_rds_engine_version.mysql.version

  # Sin contraseña Terraform: RDS crea secreto rds!db-*. Con rotación en root: password aquí y secreto JSON aparte.
  db_name  = var.database_name
  username = var.master_username

  # password y manage_master_user_password son mutuamente excluyentes en el provider AWS.
  manage_master_user_password = var.manage_master_user_password ? true : null
  password                    = var.manage_master_user_password ? null : var.master_password

  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  multi_az          = var.multi_az

  publicly_accessible    = false
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.mysql_security_group_id]

  storage_type      = "gp3"
  storage_encrypted = true

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  skip_final_snapshot       = true
  final_snapshot_identifier = null
  deletion_protection       = false

  performance_insights_enabled = false

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-mysql-${var.environment}"
    }
  )

  # Tras rotación Lambda estable: descomentar para que Terraform no sobrescriba password.
  # lifecycle {
  #   ignore_changes = [password]
  # }
}
