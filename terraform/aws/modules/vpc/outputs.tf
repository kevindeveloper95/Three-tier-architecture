output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "private_webapp_subnet_1_id" {
  description = "ID de la subnet privada webapp (AZ 1)."
  value       = aws_subnet.private_webapp_1.id
}

output "private_webapp_subnet_2_id" {
  description = "ID de la subnet privada webapp (AZ 2)."
  value       = aws_subnet.private_webapp_2.id
}

output "private_data_subnet_1_id" {
  description = "ID de la subnet privada capa datos (AZ 1)."
  value       = aws_subnet.private_data_1.id
}

output "private_data_subnet_2_id" {
  description = "ID de la subnet privada capa datos (AZ 2)."
  value       = aws_subnet.private_data_2.id
}

output "public_subnet_1_id" {
  description = "ID of the first public subnet"
  value       = aws_subnet.public_1.id
}

output "public_subnet_2_id" {
  description = "ID of the second public subnet"
  value       = aws_subnet.public_2.id
}
