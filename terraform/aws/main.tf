terraform {
  required_version = ">= 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Estado remoto (Terraform Cloud o S3+DynamoDB): descomenta y ajusta valores.
  # cloud {
  #   organization = "tu-organizacion"
  #   workspaces {
  #     name = "ritual-roast-aws"
  #   }
  # }

  # backend "s3" {
  #   bucket         = "tu-bucket-terraform-state"
  #   key            = "aws/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  s3_bucket_name_effective = trimspace(var.s3_bucket_name) != "" ? var.s3_bucket_name : lower("${var.project_name}-${var.environment}-${data.aws_caller_identity.current.account_id}-${var.aws_region}")

  # Contraseña maestra: generada por random_password o rds_mysql_password según flags de secretos/rotación.
  rds_master_password_effective = var.create_mysql_credentials_secret ? (
    var.rds_mysql_password != null ? var.rds_mysql_password : random_password.mysql_credentials[0].result
    ) : (
    var.rds_mysql_enable_secret_rotation ? (
      var.rds_mysql_password != null ? var.rds_mysql_password : random_password.mysql_rotation_only[0].result
    ) : var.rds_mysql_password
  )

  # Nombre fijo del secreto JSON para EC2 y Lambda (el ARN lleva sufijo aleatorio de AWS).
  mysql_credentials_secret_name = var.create_mysql_credentials_secret ? "${var.project_name}-mysql-credentials-${var.environment}" : (
    var.rds_mysql_enable_secret_rotation ? "${var.project_name}-mysql-rotation-${var.environment}" : ""
  )

  # Secreto maestro rds!db-* de RDS solo si no hay contraseña en Terraform (sin rotación/credenciales propias).
  rds_use_managed_master_password = local.rds_master_password_effective == null
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_password" "mysql_credentials" {
  count = var.create_mysql_credentials_secret && var.rds_mysql_password == null ? 1 : 0

  length  = 24
  special = false
}

resource "random_password" "mysql_rotation_only" {
  count = var.rds_mysql_enable_secret_rotation && !var.create_mysql_credentials_secret && var.rds_mysql_password == null ? 1 : 0

  length  = 24
  special = false
}

module "ec2_ssm_role" {
  source = "./modules/ec2-ssm-role"

  project_name = var.project_name
  environment  = var.environment

  aws_region     = var.aws_region
  aws_account_id = data.aws_caller_identity.current.account_id

  secretsmanager_extra_secret_arns = var.ec2_secretsmanager_extra_arns

  tags = {
    Name = "${var.project_name}-ec2-ssm-role-${var.environment}"
  }
}

module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names

  tags = {
    Name = "${var.project_name}-vpc-${var.environment}"
  }
}


module "app_bucket" {
  source = "./modules/s3-bucket"

  bucket_name        = local.s3_bucket_name_effective
  versioning_enabled = var.s3_bucket_versioning_enabled
  force_destroy      = var.s3_bucket_force_destroy

  tags = {
    Name = "${var.project_name}-bucket-${var.environment}"
  }
}

module "security_groups" {
  source = "./modules/security-groups"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id

  tags = {
    Name = "${var.project_name}-security-groups-${var.environment}"
  }
}

module "web_app_launch_template" {
  source = "./modules/ec2-launch-template"

  project_name = var.project_name
  environment  = var.environment

  instance_type = var.ec2_launch_template_instance_type

  vpc_security_group_ids = [module.security_groups.web_app_security_group_id]

  iam_instance_profile_name = module.ec2_ssm_role.instance_profile_name

  user_data_base64 = base64encode(templatefile("${path.module}/templates/ec2-user-data.sh.tpl", {
    s3_bucket_name      = local.s3_bucket_name_effective
    aws_region          = var.aws_region
    mysql_secret_name   = local.mysql_credentials_secret_name
    mysql_database_name = var.rds_mysql_database_name
  }))

  root_volume_gb = var.ec2_launch_template_root_volume_gb

  tags = {
    Name = "${var.project_name}-web-lt-${var.environment}"
  }
}

module "alb_target_group" {
  source = "./modules/alb-target-group"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  target_port       = 5000
  health_check_path = "/health"

  tags = {
    Name = "${var.project_name}-tg-${var.environment}"
  }
}

module "alb" {
  source = "./modules/alb"

  project_name       = var.project_name
  environment        = var.environment
  public_subnet_ids  = [module.vpc.public_subnet_1_id, module.vpc.public_subnet_2_id]
  security_group_ids = [module.security_groups.alb_security_group_id]
  target_group_arn   = module.alb_target_group.arn
  listener_http_port = 80

  tags = {
    Name = "${var.project_name}-alb-${var.environment}"
  }
}

module "web_app_asg" {
  count = var.web_app_asg_enable ? 1 : 0

  source = "./modules/asg-web-app"

  project_name = var.project_name
  environment  = var.environment

  launch_template_id      = module.web_app_launch_template.launch_template_id
  launch_template_version = tostring(module.web_app_launch_template.launch_template_latest_version)

  private_subnet_ids = [
    module.vpc.private_webapp_subnet_1_id,
    module.vpc.private_webapp_subnet_2_id,
  ]

  target_group_arn = module.alb_target_group.arn

  min_size                  = var.web_app_asg_min_size
  max_size                  = var.web_app_asg_max_size
  desired_capacity          = var.web_app_asg_desired_capacity
  health_check_grace_period = var.web_app_asg_health_check_grace_period

  tags = {
    Name = "${var.project_name}-web-asg-${var.environment}"
  }

  depends_on = [
    module.web_app_launch_template,
    module.alb_target_group,
    module.alb,
  ]
}

module "db_subnet_group" {
  source = "./modules/db-subnet-group"

  project_name = var.project_name
  environment  = var.environment
  subnet_ids = [
    module.vpc.private_data_subnet_1_id,
    module.vpc.private_data_subnet_2_id,
  ]

  tags = {
    Name = "${var.project_name}-db-subnet-group-${var.environment}"
  }
}

# Rotación MySQL en VPC vía SAR cuando no se indica rds_mysql_secret_rotation_lambda_arn.
module "mysql_rotation_sar_lambda" {
  count = var.rds_mysql_enable_secret_rotation && trimspace(var.rds_mysql_secret_rotation_lambda_arn) == "" && var.rds_mysql_rotation_lambda_deploy_in_vpc ? 1 : 0

  source = "./modules/mysql-rotation-lambda-sar"

  project_name             = var.project_name
  environment              = var.environment
  aws_region               = var.aws_region
  lambda_security_group_id = module.security_groups.mysql_security_group_id
  private_subnet_ids = [
    module.vpc.private_data_subnet_1_id,
    module.vpc.private_data_subnet_2_id,
  ]

  tags = {
    Name = "${var.project_name}-mysql-rotation-sar-${var.environment}"
  }
}

module "rds_mysql" {
  source = "./modules/rds-aurora-mysql"

  project_name            = var.project_name
  environment             = var.environment
  database_name           = var.rds_mysql_database_name
  master_username               = var.rds_mysql_username
  master_password               = local.rds_master_password_effective
  manage_master_user_password = local.rds_use_managed_master_password
  instance_class              = var.rds_mysql_instance_class
  allocated_storage       = var.rds_mysql_allocated_storage
  multi_az                = var.rds_mysql_multi_az
  db_subnet_group_name    = module.db_subnet_group.db_subnet_group_name
  mysql_security_group_id = module.security_groups.mysql_security_group_id

  tags = {
    Name = "${var.project_name}-mysql-${var.environment}"
  }
}

module "mysql_credentials_secret" {
  count = var.create_mysql_credentials_secret ? 1 : 0

  source = "./modules/mysql-credentials-secret"

  project_name = var.project_name
  environment  = var.environment

  db_host     = module.rds_mysql.db_instance_address
  db_port     = module.rds_mysql.db_instance_port
  db_database = var.rds_mysql_database_name
  db_username = var.rds_mysql_username
  db_password = local.rds_master_password_effective

  tags = {
    Name = "${var.project_name}-mysql-credentials-${var.environment}"
  }

  depends_on = [module.rds_mysql]
}

# Secreto JSON solo para rotación si create_mysql_credentials_secret es false.
module "mysql_rotation_only_secret" {
  count = var.rds_mysql_enable_secret_rotation && !var.create_mysql_credentials_secret ? 1 : 0

  source = "./modules/mysql-credentials-secret"

  project_name      = var.project_name
  environment       = var.environment
  secret_name_slug  = "mysql-rotation"
  db_host           = module.rds_mysql.db_instance_address
  db_port           = module.rds_mysql.db_instance_port
  db_database       = var.rds_mysql_database_name
  db_username       = var.rds_mysql_username
  db_password       = local.rds_master_password_effective

  tags = {
    Name = "${var.project_name}-mysql-rotation-${var.environment}"
  }

  depends_on = [module.rds_mysql]
}

# Rotación Lambda sobre el secreto JSON propio (no el rds!db-* de RDS).
module "rds_mysql_master_secret_rotation" {
  count = var.rds_mysql_enable_secret_rotation ? 1 : 0

  source = "./modules/rds-mysql-master-secret-rotation"

  secret_id = var.create_mysql_credentials_secret ? module.mysql_credentials_secret[0].secret_arn : module.mysql_rotation_only_secret[0].secret_arn

  aws_region               = var.aws_region
  automatically_after_days = var.rds_mysql_secret_rotation_days
  rotation_lambda_arn = trimspace(var.rds_mysql_secret_rotation_lambda_arn) != "" ? trimspace(var.rds_mysql_secret_rotation_lambda_arn) : (
    length(module.mysql_rotation_sar_lambda) > 0 ? module.mysql_rotation_sar_lambda[0].rotation_lambda_arn : ""
  )

  depends_on = [
    module.rds_mysql,
    module.mysql_rotation_sar_lambda,
    module.mysql_credentials_secret,
    module.mysql_rotation_only_secret,
  ]
}

