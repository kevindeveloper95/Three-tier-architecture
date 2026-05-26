# Amazon Linux 2023: Python 3.9+ (AL2 trae 3.7 y rompe requirements.txt con Flask 3.1 / blinker 1.9)
data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_launch_template" "web" {
  name          = "${var.project_name}-web-app-${var.environment}"
  image_id      = nonsensitive(data.aws_ssm_parameter.amazon_linux_2023.value)
  instance_type = var.instance_type

  vpc_security_group_ids = var.vpc_security_group_ids

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  user_data = var.user_data_base64

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_gb
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.project_name}-web-app-${var.environment}"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      var.tags,
      {
        Name = "${var.project_name}-web-app-root-${var.environment}"
      }
    )
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-web-lt-${var.environment}"
    }
  )

  update_default_version = true
}
