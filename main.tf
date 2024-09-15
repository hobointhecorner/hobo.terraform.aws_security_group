terraform {
  required_version = ">=1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.0.0"
    }
  }
}

resource "aws_security_group" "security_group" {
  for_each = var.name != null ? [var.name] : []

  name        = var.name
  vpc_id      = var.vpc_id
  description = var.description

  tags = merge(var.tags, {
    Name = var.display_name != null ? var.display_name : var.name
  })
}

resource "aws_security_group_rule" "rules" {
  for_each = var.rules

  security_group_id        = var.security_group_id != null ? var.security_group_id : aws_security_group.security_group[var.name].id
  type                     = each.value.type
  protocol                 = each.value.protocol
  from_port                = each.value.from_port
  to_port                  = each.value.to_port != null ? each.value.to_port : each.value.from_port
  source_security_group_id = each.value.security_group_id
  cidr_blocks              = each.value.cidr_blocks
  ipv6_cidr_blocks         = each.value.ipv6_cidr_blocks
  prefix_list_ids          = each.value.prefix_list_ids
  self                     = each.value.self
}
