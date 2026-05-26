output "rotation_lambda_arn" {
  description = "ARN de la Lambda desplegada por el stack SAR (para aws_secretsmanager_secret_rotation)."
  value       = aws_serverlessapplicationrepository_cloudformation_stack.mysql_rotation.outputs["RotationLambdaARN"]
}

output "rotation_lambda_security_group_id" {
  description = "ID del SG pasado a la Lambda (en la raíz: el mismo que mysql_security_group_id)."
  value       = var.lambda_security_group_id
}

output "cloudformation_stack_name" {
  description = "Nombre del stack de CloudFormation del SAR."
  value       = aws_serverlessapplicationrepository_cloudformation_stack.mysql_rotation.name
}
