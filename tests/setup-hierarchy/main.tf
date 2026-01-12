terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 18.7.0"
    }
  }
}

module "gitlab_group_level_0" {
  source = "../../"

  initial_group_id = var.initial_group_id
  group_details    = local.group_hierarchy
}
module "gitlab_group_level_1" {
  source = "../../"

  parent_group_level = module.gitlab_group_level_0
  group_details      = local.group_hierarchy
}
module "gitlab_group_level_2" {
  source = "../../"

  parent_group_level = module.gitlab_group_level_1
  group_details      = local.group_hierarchy
}
module "gitlab_group_level_3" {
  source = "../../"

  parent_group_level = module.gitlab_group_level_2
  group_details      = local.group_hierarchy
}
module "gitlab_group_level_4" {
  source = "../../"

  parent_group_level = module.gitlab_group_level_3
  group_details      = local.group_hierarchy
}
module "gitlab_group_level_5" {
  source = "../../"

  parent_group_level = module.gitlab_group_level_4
  group_details      = local.group_hierarchy
}

locals {
  group_hierarchy = {
    "aa"          = { visibility_level = "private" }
    "aa/bb"       = { visibility_level = "private" }
    "aa/cc"       = { visibility_level = "private" }
    "aa/cc/dd"    = { visibility_level = "private" }
    "aa/cc/dd/ee" = { visibility_level = "private" }
  }
}

variable "gitlab_pat" {
  type = string
}
variable "initial_group_id" {
  type = number
}