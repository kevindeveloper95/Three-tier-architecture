# Preserva el estado al renombrar subnets privadas webapp (Terraform 1.1+).
moved {
  from = aws_subnet.private_1
  to   = aws_subnet.private_webapp_1
}

moved {
  from = aws_subnet.private_2
  to   = aws_subnet.private_webapp_2
}

moved {
  from = aws_route_table_association.private_1
  to   = aws_route_table_association.private_webapp_1
}

moved {
  from = aws_route_table_association.private_2
  to   = aws_route_table_association.private_webapp_2
}
