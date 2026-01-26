terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 18.7.0"
    }
  }
}

locals {
  level_depth = var.parent_group_level != null ? var.parent_group_level.level_depth + 1 : 0

  parent_group_resources = var.parent_group_level != null ? var.parent_group_level.group_resources : {
    "" : {
      id        = data.gitlab_group.initial_group[0].id
      full_name = data.gitlab_group.initial_group[0].full_name
      path      = data.gitlab_group.initial_group[0].path
      full_path = data.gitlab_group.initial_group[0].full_path
      name      = data.gitlab_group.initial_group[0].name
      full_name = data.gitlab_group.initial_group[0].full_name
      #runners_token = data.gitlab_group.initial_group[0].runners_token # sofar can not pass object with a sensitive value through for loops
      web_url = data.gitlab_group.initial_group[0].web_url
    }
  }
  group_details_filtered = merge([
    for parent_full_name in keys(local.parent_group_resources) : {
      for full_name, details in var.group_details : full_name => details
      if length(split("/", full_name)) == local.level_depth && startswith(full_name, parent_full_name)
    }
  ]...)
}

data "gitlab_group" "initial_group" {
  count = var.initial_group_id == null ? 0 : 1

  group_id = var.initial_group_id
}

resource "gitlab_group" "level_group" {
  for_each = tomap(local.group_details_filtered)

  parent_id = local.parent_group_resources[trimsuffix(each.key, regex("(?:^|/)[^/]+$", each.key))].id
  name      = each.value.name != null ? each.value.name : (local.level_depth > 1 ? trimprefix(each.key, regex("^.*/", each.key)) : each.key)
  path      = each.value.path != null ? each.value.path : (local.level_depth > 1 ? trimprefix(each.key, regex("^.*/", each.key)) : each.key)

  allowed_email_domains_list = each.value.allowed_email_domains_list
  auto_devops_enabled        = each.value.auto_devops_enabled
  avatar                     = each.value.avatar
  default_branch             = each.value.default_branch
  default_branch_protection  = each.value.default_branch_protection
  dynamic "default_branch_protection_defaults" {
    for_each = each.value.default_branch_protection_defaults != null ? [each.value.default_branch_protection_defaults] : []
    content {
      allow_force_push           = setting.value.allow_force_push
      allowed_to_merge           = setting.value.allowed_to_merge
      allowed_to_push            = setting.value.allowed_to_push
      developer_can_initial_push = setting.value.developer_can_initial_push
    }
  }
  description                        = each.value.description
  emails_enabled                     = each.value.emails_enabled
  extra_shared_runners_minutes_limit = each.value.extra_shared_runners_minutes_limit
  ip_restriction_ranges              = each.value.ip_restriction_ranges
  lfs_enabled                        = each.value.lfs_enabled
  membership_lock                    = each.value.membership_lock
  mentions_disabled                  = each.value.mentions_disabled
  permanently_remove_on_delete       = each.value.permanently_remove_on_delete
  prevent_forking_outside_group      = each.value.prevent_forking_outside_group
  project_creation_level             = each.value.project_creation_level
  dynamic "push_rules" {
    for_each = each.value.push_rules != null ? [each.value.push_rules] : []
    content {
      author_email_regex            = push_rules.value.author_email_regex
      branch_name_regex             = push_rules.value.branch_name_regex
      commit_committer_check        = push_rules.value.commit_committer_check
      commit_committer_name_check   = push_rules.value.commit_committer_name_check
      commit_message_negative_regex = push_rules.value.commit_message_negative_regex
      commit_message_regex          = push_rules.value.commit_message_regex
      deny_delete_tag               = push_rules.value.deny_delete_tag
      file_name_regex               = push_rules.value.file_name_regex
      max_file_size                 = push_rules.value.max_file_size
      member_check                  = push_rules.value.member_check
      prevent_secrets               = push_rules.value.prevent_secrets
      reject_non_dco_commits        = push_rules.value.reject_non_dco_commits
      reject_unsigned_commits       = push_rules.value.reject_unsigned_commits
    }
  }
  request_access_enabled            = each.value.request_access_enabled
  require_two_factor_authentication = each.value.require_two_factor_authentication
  share_with_group_lock             = each.value.share_with_group_lock
  shared_runners_minutes_limit      = each.value.shared_runners_minutes_limit
  shared_runners_setting            = each.value.shared_runners_setting
  subgroup_creation_level           = each.value.subgroup_creation_level
  two_factor_grace_period           = each.value.two_factor_grace_period
  visibility_level                  = each.value.visibility_level
  wiki_access_level                 = each.value.wiki_access_level
}

check "input_variables" {
  assert {
    condition     = (var.initial_group_id == null) != (var.parent_group_level == null)
    error_message = "need to specify either initial_group_id or parent_group_level"
  }
}

variable "initial_group_id" {
  type        = number
  default     = null
  description = "Identifier of initial gitlab group which hosts all other sub groups"
}
variable "parent_group_level" {
  type        = any
  default     = null
  description = "Output object from parent group level module"
}

variable "group_details" {
  description = "Group details, passed through to gitlab_group resource (for more information please reference to https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/group#optional)"
  type = map(object({
    name                       = optional(string)
    path                       = optional(string)
    allowed_email_domains_list = optional(list(string))
    auto_devops_enabled        = optional(bool)
    avatar                     = optional(string)
    default_branch             = optional(string)
    default_branch_protection  = optional(number)
    default_branch_protection_defaults = optional(object({
      allow_force_push           = optional(bool)
      allowed_to_merge           = optional(list(string))
      allowed_to_push            = optional(list(string))
      developer_can_initial_push = optional(bool)
    }))
    description                        = optional(string)
    emails_enabled                     = optional(bool)
    extra_shared_runners_minutes_limit = optional(number)
    ip_restriction_ranges              = optional(list(string))
    lfs_enabled                        = optional(bool)
    membership_lock                    = optional(bool)
    mentions_disabled                  = optional(bool)
    parent_id                          = optional(number)
    permanently_remove_on_delete       = optional(bool)
    prevent_forking_outside_group      = optional(bool)
    project_creation_level             = optional(string)
    push_rules = optional(object({
      author_email_regex            = optional(string)
      branch_name_regex             = optional(string)
      commit_committer_check        = optional(bool)
      commit_committer_name_check   = optional(bool)
      commit_message_negative_regex = optional(string)
      commit_message_regex          = optional(string)
      deny_delete_tag               = optional(bool)
      file_name_regex               = optional(bool)
      max_file_size                 = optional(number)
      member_check                  = optional(bool)
      prevent_secrets               = optional(bool)
      reject_non_dco_commits        = optional(bool)
      reject_unsigned_commits       = optional(bool)
    }))
    request_access_enabled            = optional(bool)
    require_two_factor_authentication = optional(bool)
    share_with_group_lock             = optional(bool)
    shared_runners_minutes_limit      = optional(number)
    shared_runners_setting            = optional(string)
    subgroup_creation_level           = optional(string)
    two_factor_grace_period           = optional(number)
    visibility_level                  = optional(string)
    wiki_access_level                 = optional(string)
  }))
}

output "level_depth" {
  value = local.level_depth
}
output "group_resources" {
  value = local.level_depth > 0 ? {
    for full_name, details in local.group_details_filtered : full_name => gitlab_group.level_group[full_name]
  } : local.parent_group_resources
}
