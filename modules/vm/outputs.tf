output "ip_servers" {
  description = "IP públicas de los servidores EC2"
  value = [
    for key, instance in aws_instance.vm_devops : {
      name       = key
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
      instance_id = instance.id
    }
  ]
}

output "instance_ids" {
  description = "IDs de las instancias EC2"
  value       = { for key, instance in aws_instance.vm_devops : key => instance.id }
}

output "security_group_id" {
  description = "ID del Security Group"
  value       = aws_security_group.devops_sg.id
}