output "rotation_id" {
  description = "ID de la configuración de rotación en Secrets Manager."
  value       = aws_secretsmanager_secret_rotation.rds_mysql_master.id
}

output "rotation_lambda_arn_effective" {
  description = "ARN de la Lambda usada para la rotación."
  value       = local.rotation_lambda_arn_effective
}
