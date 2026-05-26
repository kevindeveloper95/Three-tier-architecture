output "bucket_id" {
  description = "ID del bucket (normalmente el nombre)."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN del bucket."
  value       = aws_s3_bucket.this.arn
}

output "bucket_name" {
  description = "Nombre del bucket."
  value       = aws_s3_bucket.this.bucket
}

