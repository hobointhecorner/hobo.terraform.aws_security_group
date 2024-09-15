output "id" {
  value = var.name != null ? aws_security_group.security_group[var.name].id : null
}

output "rules" {
  value = var.rules != {} ? var.rules : null
}

output "security_group" {
  value = var.name != null ? aws_security_group.security_group[var.name] : null
}
