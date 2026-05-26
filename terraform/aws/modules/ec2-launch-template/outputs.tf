output "launch_template_id" {
  description = "ID del launch template."
  value       = aws_launch_template.web.id
}

output "launch_template_arn" {
  description = "ARN del launch template."
  value       = aws_launch_template.web.arn
}

output "launch_template_name" {
  description = "Nombre del launch template."
  value       = aws_launch_template.web.name
}

output "launch_template_latest_version" {
  description = "Última versión del launch template."
  value       = aws_launch_template.web.latest_version
}
