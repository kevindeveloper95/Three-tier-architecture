# Rotación Lambda sobre secreto JSON propio (engine/host/...); no usar con secretos rds!db-* de RDS.
locals {
  default_rotation_lambda_arn = format(
    "arn:aws:lambda:%s:297356227824:function:SecretsManagerRDSMySQLRotationSingleUser",
    var.aws_region
  )
  rotation_lambda_arn_effective = trimspace(var.rotation_lambda_arn) != "" ? trimspace(var.rotation_lambda_arn) : local.default_rotation_lambda_arn
}

resource "aws_secretsmanager_secret_rotation" "rds_mysql_master" {
  secret_id           = var.secret_id
  rotation_lambda_arn = local.rotation_lambda_arn_effective

  rotation_rules {
    automatically_after_days = var.automatically_after_days
  }
}
