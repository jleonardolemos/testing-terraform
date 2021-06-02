output "vpc_id" {
    description = "The VPC ID"
    value       = "ID: ${module.network.vpc_id}"
}