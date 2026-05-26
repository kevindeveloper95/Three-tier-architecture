output "role_name" {
  description = "Name of the IAM role for EC2 with Systems Manager and S3 access"
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "ARN of the IAM role for EC2 with Systems Manager and S3 access"
  value       = aws_iam_role.this.arn
}

output "instance_profile_name" {
  description = "Name of the instance profile for EC2"
  value       = aws_iam_instance_profile.this.name
}
