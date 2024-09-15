#
# Create a new security group
#

# required
variable "name" {
  type        = string
  default     = null
  description = "Create a new security group with this name"
}

# required
variable "vpc_id" {
  type        = string
  default     = null
  description = "Create a new security group in the provided VPC. Required when var.name is defined"
}

variable "display_name" {
  type        = string
  default     = null
  description = "Sets the 'Name' tag on a new security group, also shown as the display name in the AWS console"
}

variable "description" {
  type        = string
  default     = null
  description = "Description of the newly-created security group"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to be applied to the newly-created security group"
}

#
# Use an existing security group
#

# required
variable "security_group_id" {
  type        = string
  default     = null
  description = "ID of an existing security group to which you wish to apply rules"
}

#
# Security group rules
#

# Required when using an existing security group
variable "rules" {
  type = map(object({
    type      = string
    protocol  = string
    from_port = number
    to_port   = optional(number)

    # Exactly one of the below must be provided
    security_group_id = optional(string)
    cidr_blocks       = optional(list(string))
    ipv6_cidr_blocks  = optional(list(string))
    prefix_list_ids   = optional(list(string))
    self              = optional(bool)
  }))

  default     = {}
  description = <<-DESC
    One or more security group rules in the following format.

    Exactly one of the following properties must be provided per rule: "security_group_id", "cidr_blocks", "ipv6_cidr_blocks", "prefix_list_ids", "self"
  DESC
}

#
# Validate inputs
#

locals {
  variable_validation_error = <<-DESC
    The following variables must be defined:
      * When creating a new security group: name, vpc_id
      * When applying rules to an existing security group: security_group_id, rules
  DESC

  rule_targets = ["security_group_id", "cidr_blocks", "ipv6_cidr_blocks", "prefix_list_ids", "self"]
}

check "variable_validation" {
  # Ensure exactly one of var.name and var.security_group_id are defined
  assert {
    condition     = (var.name != null && var.security_group_id == null) || (var.name == null && var.security_group_id != null)
    error_message = local.variable_validation_error
  }

  # Ensure all required variables are provided
  assert {
    condition     = (var.name != null && var.vpc_id != null) || (var.security_group_id != null && var.rules != {})
    error_message = local.variable_validation_error
  }

  # Ensure valid target is defined for every rule
  assert {
    condition = length([for rule in var.rules :
      [for target in local.rule_targets : rule[target]
        if rule[target] != null
      ]
    ]) == 1

    error_message = "Exactly one of the following must be provided per security group rule: '${join("', '", local.rule_targets)}'"
  }

  # Ensure valid type for every rule
  assert {
    condition = length([for rule in var.rules : rule.type
      if rule.type != "ingress" && rule.type != "egress"
    ]) == 0
    error_message = "Security group rule type must be either 'ingress' or 'egress'"
  }
}
