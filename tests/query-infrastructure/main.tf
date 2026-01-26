terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 18.7.0"
    }
  }
}

data "gitlab_group" "initial_group" {
  group_id = var.initial_group_id
}

variable "initial_group_id" {
  type    = number
  default = null
}

output "initial_group" {
  value     = data.gitlab_group.initial_group
  sensitive = true
}