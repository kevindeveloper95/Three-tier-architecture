output "secret_arn" {
  description = "ARN del secreto (p. ej. RDS_MYSQL_SECRET_ARN en la app EC2)."
  value       = aws_secretsmanager_secret.mysql.arn
}

output "secret_id" {
  description = "ID del secreto."
  value       = aws_secretsmanager_secret.mysql.id
}

output "secret_name" {
  description = "Nombre del secreto."
  value       = aws_secretsmanager_secret.mysql.name
}
