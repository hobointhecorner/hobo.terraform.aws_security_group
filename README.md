# hobo.terraform.aws_security_group
Easily create AWS security groups and/or apply security group rules using the `aws_security_group_rule` resource with terraform.

## Variables
### Creating a new security group

|        Name       | Required | Description |
|-------------------|----------|-------------|
|        name       |    yes   | Name of the new security group to be created |
|       vpc_id      |    yes   | ID of the VPC in which the new security group will be created |
|    display_name   |    no    | Sets the 'Name' tag on a new security group, also shown as the display name in the AWS console |
|    description    |    no    | A brief description of the new security group |
|       tags        |    no    | Tags to be applied to the new security group |
|       rules       |    no    | One or more rules to apply to the security group |

### Applying rules to an existing security group

|       Name        | Required | Description |
|-------------------|----------|-------------|
| security_group_id |    yes   | ID of an existing security group to which rules will be applied |
|       rules       |    yes   | One or more rules to apply to the security group |

**NOTE**: Do not add `ingress` or `egress` blocks within the `aws_security_group` resource when using this module to apply security group rules to an existing security group

## Rules

When applying security group rules using the `rules` variable, they must be in the following format:

```hcl
{
  some_identifier = {
    type      = string
    protocol  = string
    from_port = number
    to_port   = optional(number, default = from_port)

    # Exactly one of the below must be provided
    security_group_id   = optional(string)
    cidr_blocks         = optional(list(string))
    ipv6_cidr_blocks    = optional(list(string))
    prefix_list_ids     = optional(list(string))
    self                = optional(bool)
  },

  another_identifier = {
    ...
  }
}
```

## Examples
### Creating a new security group

```hcl
module "example" {
  source = "github.com/hobointhecorner/hobo.terraform.aws_security_group?ref=v1"

  name   = "example_security_group"
  vpc_id = "vpc-1234567890"
  rules = {
    some_identifier    = { type = ... }
    another_identifier = { type = ... }
  }
}
```

### Applying rules to an existing security group

```hcl
resource "aws_security_group" "example" {
  name = "example_security_group"
  vpc_id = "vpc-1234567890"

  tags = {
    Name = "example_security_group"
  }
}

module "example" {
  source = "github.com/hobointhecorner/hobo.terraform.aws_security_group?ref=v1"

  security_group_id = aws_security_group.example.id
  rules = {
    some_identifier    = { type = ... }
    another_identifier = { type = ... }
  }
}
```

### Security groups that reference each other

```hcl
module "example_server" {
  source = "github.com/hobointhecorner/hobo.terraform.aws_security_group?ref=v1"

  name   = "example_server_security_group"
  vpc_id = "vpc-1234567890"
}

module "example_server_rules {
  source = "github.com/hobointhecorner/hobo.terraform.aws_security_group?ref=v1"

  security_group_id = module.example_server.security_group.id
  rules = {
    some_identifier = { security_group_id = module.example_client.security_group.id, type = ... }
  }
}

module "example_client" {
  source = "github.com/hobointhecorner/hobo.terraform.aws_security_group?ref=v1"

  name   = "example_client_security_group"
  vpc_id = "vpc-1234567890"
}

module "example_client_rules {
  source = "github.com/hobointhecorner/hobo.terraform.aws_security_group?ref=v1"

  security_group_id = module.example_client.security_group.id
  rules = {
    some_identifier = { security_group_id = module.example_server.security_group.id, type = ... }
  }
}
```
