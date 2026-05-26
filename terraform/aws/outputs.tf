
output "vpc_id" {
  description = "ID de la VPC."
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR de la VPC."
  value       = module.vpc.vpc_cidr_block
}

output "private_webapp_subnet_ids" {
  description = "IDs de subnets privadas webapp (ASG, EKS)."
  value = [
    module.vpc.private_webapp_subnet_1_id,
    module.vpc.private_webapp_subnet_2_id,
  ]
}

output "private_data_subnet_ids" {
  description = "IDs de subnets privadas capa datos (RDS, ElastiCache, Lambda rotación)."
  value = [
    module.vpc.private_data_subnet_1_id,
    module.vpc.private_data_subnet_2_id,
  ]
}

output "public_subnet_ids" {
  description = "IDs de subnets públicas."
  value = [
    module.vpc.public_subnet_1_id,
    module.vpc.public_subnet_2_id,
  ]
}


output "s3_bucket_name" {
  description = "Nombre del bucket S3."
  value       = module.app_bucket.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN del bucket S3."
  value       = module.app_bucket.bucket_arn
}

output "web_app_security_group_id" {
  description = "ID del security group de la web app."
  value       = module.security_groups.web_app_security_group_id
}

output "alb_security_group_id" {
  description = "ID del security group del Application Load Balancer."
  value       = module.security_groups.alb_security_group_id
}

output "alb_dns_name" {
  description = "DNS público del Application Load Balancer."
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "ARN del Application Load Balancer."
  value       = module.alb.alb_arn
}

output "alb_target_group_arn" {
  description = "ARN del target group HTTP (backend puerto 5000)."
  value       = module.alb_target_group.arn
}

output "alb_target_group_name" {
  description = "Nombre del target group del ALB."
  value       = module.alb_target_group.name
}

output "ec2_ssm_role_name" {
  description = "Nombre del rol IAM para EC2 con acceso a Systems Manager y S3."
  value       = module.ec2_ssm_role.role_name
}

output "ec2_ssm_role_arn" {
  description = "ARN del rol IAM para EC2 con acceso a Systems Manager y S3."
  value       = module.ec2_ssm_role.role_arn
}

output "ec2_instance_profile_name" {
  description = "Nombre del instance profile que debes asociar a la EC2 o launch template."
  value       = module.ec2_ssm_role.instance_profile_name
}

output "ec2_web_launch_template_id" {
  description = "ID del launch template de la web app (Amazon Linux 2, t2.micro, SG web app, rol EC2 SSM)."
  value       = module.web_app_launch_template.launch_template_id
}

output "ec2_web_launch_template_arn" {
  description = "ARN del launch template de la web app."
  value       = module.web_app_launch_template.launch_template_arn
}

output "ec2_web_launch_template_latest_version" {
  description = "Versión por defecto del launch template (última)."
  value       = module.web_app_launch_template.launch_template_latest_version
}

output "web_app_autoscaling_group_name" {
  description = "Nombre del ASG web (si web_app_asg_enable = true)."
  value       = try(module.web_app_asg[0].autoscaling_group_name, null)
}

output "web_app_autoscaling_group_arn" {
  description = "ARN del ASG web."
  value       = try(module.web_app_asg[0].autoscaling_group_arn, null)
}

output "rds_mysql_master_user_secret_arn" {
  description = "ARN del secreto maestro gestionado por RDS (solo si rds_mysql_password es null y rds_mysql_enable_secret_rotation es false)."
  value       = try(module.rds_mysql.master_user_secret_arn, null)
}

output "rds_mysql_credentials_secret_name" {
  description = "Nombre del secreto JSON para la app EC2 y rotación Lambda (GetSecretValue por nombre)."
  value       = local.mysql_credentials_secret_name != "" ? local.mysql_credentials_secret_name : null
}

output "rds_mysql_rotation_secret_arn" {
  description = "ARN del secreto JSON rotado por Lambda cuando rds_mysql_enable_secret_rotation es true (mysql-credentials o mysql-rotation según flags)."
  value = var.rds_mysql_enable_secret_rotation ? (
    var.create_mysql_credentials_secret ? module.mysql_credentials_secret[0].secret_arn : module.mysql_rotation_only_secret[0].secret_arn
  ) : null
}

output "rds_mysql_secret_rotation_lambda_arn" {
  description = "Lambda usada para rotar el secreto JSON maestro (solo si rds_mysql_enable_secret_rotation es true)."
  value       = try(module.rds_mysql_master_secret_rotation[0].rotation_lambda_arn_effective, null)
}

output "rds_mysql_rotation_sar_stack_name" {
  description = "Nombre del stack CloudFormation del SAR de rotación MySQL (si se desplegó en VPC)."
  value       = try(module.mysql_rotation_sar_lambda[0].cloudformation_stack_name, null)
}
