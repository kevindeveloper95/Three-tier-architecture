output "alb_id" {
  description = "ID del Application Load Balancer."
  value       = aws_lb.this.id
}

output "alb_arn" {
  description = "ARN del Application Load Balancer."
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS público del ALB (apunta aquí el dominio o pruebas)."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID del ALB (para alias Route53)."
  value       = aws_lb.this.zone_id
}

output "listener_http_arn" {
  description = "ARN del listener HTTP (puerto frontal)."
  value       = aws_lb_listener.http.arn
}
