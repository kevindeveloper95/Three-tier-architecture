output "db_instance_id" {
  description = "ID of the RDS MySQL instance"
  value       = aws_db_instance.mysql.id
}

output "db_instance_endpoint" {
  description = "Endpoint for the RDS MySQL instance"
  value       = aws_db_instance.mysql.endpoint
}

output "db_instance_address" {
  description = "Address (hostname) of the RDS MySQL instance"
  value       = aws_db_instance.mysql.address
}

output "db_instance_port" {
  description = "Port for the RDS MySQL instance"
  value       = aws_db_instance.mysql.port
}

output "database_name" {
  description = "Name of the database"
  value       = aws_db_instance.mysql.db_name
}

output "db_instance_arn" {
  description = "ARN of the RDS MySQL instance"
  value       = aws_db_instance.mysql.arn
}

output "master_user_secret_arn" {
  description = "ARN del secreto en AWS Secrets Manager (presente solo si manage_master_user_password está activo)"
  value       = try(aws_db_instance.mysql.master_user_secret[0].secret_arn, null)
}
