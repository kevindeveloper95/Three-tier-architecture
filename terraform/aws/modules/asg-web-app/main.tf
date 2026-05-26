locals {
  instance_tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-web-asg-ec2-${var.environment}"
    },
  )
}

resource "aws_autoscaling_group" "web" {
  name                      = "${var.project_name}-web-asg-${var.environment}"
  vpc_zone_identifier       = var.private_subnet_ids
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  health_check_type         = "ELB"
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  dynamic "tag" {
    for_each = local.instance_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_attachment" "alb_target_group" {
  autoscaling_group_name = aws_autoscaling_group.web.name
  lb_target_group_arn    = var.target_group_arn
}
