# Gitlab Group Hierarchy

## Overview

This Terraform module manages hierarchical GitLab group structures with comprehensive configuration options. It enables creating multi-level group hierarchies and applying consistent policies across all groups.

## Features

- **Hierarchical Group Management**: Create groups at different nesting levels under a parent group or initial group

## Usage Example

```hcl
locals {
  group_details = {
    "engineering" = {
      description         = "Engineering group"
      visibility_level    = "private"
      auto_devops_enabled = true
    }
    "engineering/backend" = {
      description                       = "Backend team"
      require_two_factor_authentication = true
      shared_runners_minutes_limit      = 10000
    }
    "engineering/backend/platform" = {
      description          = "Platform team"
      project_creation_level = "developer"
    }
  }
}

module "group-hierarchy-0" {
  source  = "ghostofthecode/group-hierarchy/gitlab"
  version = "0.0.3"
  
  initial_group_id = 123  # Root group ID
  group_details    = local.group_details
}
module "group-hierarchy-1" {
  source  = "ghostofthecode/group-hierarchy/gitlab"
  version = "0.0.3"
  
  parent_group_level = module.group-hierarchy-0
  group_details      = local.group_details
}
module "group-hierarchy-2" {
  source  = "ghostofthecode/group-hierarchy/gitlab"
  version = "0.0.3"
  
  parent_group_level = module.group-hierarchy-1
  group_details      = local.group_details
}
```

## Requirements

- GitLab Provider >= 18.7.0
- Terraform >= 1.0

## Notes

- Groups are organized hierarchically based on their full paths (e.g., "parent/child")
- All group attributes are optional and use GitLab defaults when not specified