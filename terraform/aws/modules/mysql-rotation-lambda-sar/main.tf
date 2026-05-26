# SAR SecretsManagerRDSMySQLRotationSingleUser en VPC; usa el mismo SG que RDS MySQL.
data "aws_partition" "current" {}

data "aws_serverlessapplicationrepository_application" "mysql_single_user" {
  application_id = "arn:aws:serverlessrepo:${var.aws_region}:297356227824:applications/SecretsManagerRDSMySQLRotationSingleUser"
}

resource "aws_serverlessapplicationrepository_cloudformation_stack" "mysql_rotation" {
  name             = "${var.project_name}-mysql-sm-rot-${var.environment}"
  application_id   = data.aws_serverlessapplicationrepository_application.mysql_single_user.application_id
  semantic_version = data.aws_serverlessapplicationrepository_application.mysql_single_user.semantic_version
  capabilities     = data.aws_serverlessapplicationrepository_application.mysql_single_user.required_capabilities

  parameters = {
    endpoint            = "https://secretsmanager.${var.aws_region}.${data.aws_partition.current.dns_suffix}"
    functionName        = "${var.project_name}-sm-mysql-rot-${var.environment}"
    vpcSubnetIds        = join(",", var.private_subnet_ids)
    vpcSecurityGroupIds = var.lambda_security_group_id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-mysql-sm-rotation-stack-${var.environment}"
    }
  )
}
