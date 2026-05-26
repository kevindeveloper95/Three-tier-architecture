output "arn" {
  description = "ARN del target group."
  value       = aws_lb_target_group.app.arn
}

output "name" {
  description = "Nombre del target group."
  value       = aws_lb_target_group.app.name
}

output "id" {
  description = "ID del target group."
  value       = aws_lb_target_group.app.id
}
