output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "web_app_security_group_id" {
  description = "ID of the web app security group"
  value       = aws_security_group.web_app.id
}

output "mysql_security_group_id" {
  description = "ID of the MySQL security group"
  value       = aws_security_group.mysql.id
}
