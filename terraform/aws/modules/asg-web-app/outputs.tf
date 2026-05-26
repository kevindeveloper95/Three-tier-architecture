output "autoscaling_group_id" {
  description = "ID del Auto Scaling Group."
  value       = aws_autoscaling_group.web.id
}

output "autoscaling_group_name" {
  description = "Nombre del Auto Scaling Group."
  value       = aws_autoscaling_group.web.name
}

output "autoscaling_group_arn" {
  description = "ARN del Auto Scaling Group."
  value       = aws_autoscaling_group.web.arn
}
