output "manager_id" {
  description = "ID of the instance manager"
  value       = aws_instance.swarm_manager.id
}