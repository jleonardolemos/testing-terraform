output "vpc_id" {
  description = "ID of project VPC"
  value       = aws_vpc.swarm.id
}

output "subnet_id" {
  description = "ID of first public subnet"
  value       = aws_subnet.public_one.id
}

output "subnet_id_2" {
  description = "ID of second public subnet"
  value       = aws_subnet.public_two.id
}