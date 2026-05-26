resource "aws_secretsmanager_secret" "mysql" {
  name                    = "${var.project_name}-${var.secret_name_slug}-${var.environment}"
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.secret_name_slug}-${var.environment}"
    }
  )
}

resource "aws_secretsmanager_secret_version" "mysql" {
  secret_id = aws_secretsmanager_secret.mysql.id
  secret_string = jsonencode({
    engine   = "mysql"
    host     = var.db_host
    username = var.db_username
    password = var.db_password
    dbname   = var.db_database
    port     = tostring(var.db_port)
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}
