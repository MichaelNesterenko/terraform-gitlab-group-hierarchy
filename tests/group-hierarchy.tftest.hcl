variables {
  initial_group_id = 122202060
}

run "query-infrastructure" {
  module {
    source = "./tests/query-infrastructure"
  }
}

run "validate-hierarchy" {
  module {
    source = "./tests/setup-hierarchy"
  }

  assert {
    condition     = module.gitlab_group_level_0.group_resources[""].id != null
    error_message = "can not find initial parent group"
  }
  assert {
    condition     = module.gitlab_group_level_1.group_resources["aa"].id != null
    error_message = "can not find group aa"
  }
  assert {
    condition     = module.gitlab_group_level_2.group_resources["aa/bb"].id != null
    error_message = "can not find group aa/bb"
  }
  assert {
    condition     = module.gitlab_group_level_2.group_resources["aa/cc"].id != null
    error_message = "can not find group aa/cc"
  }
  assert {
    condition = (module.gitlab_group_level_2.group_resources["aa/cc"].path == "some-custom-path" &&
    module.gitlab_group_level_2.group_resources["aa/cc"].full_path == "${run.query-infrastructure.initial_group.path}/aa/some-custom-path")
    error_message = "group aa/cc must have a custom path"
  }
  assert {
    condition = (module.gitlab_group_level_3.group_resources["aa/cc/dd"].name == "some-custom-name" &&
    module.gitlab_group_level_3.group_resources["aa/cc/dd"].full_name == "${run.query-infrastructure.initial_group.name} / aa / cc / some-custom-name")
    error_message = "group aa/cc/dd must have a custom name"
  }
  assert {
    condition     = module.gitlab_group_level_3.group_resources["aa/cc/dd"].id != null
    error_message = "can not find group aa/cc/dd"
  }
  assert {
    condition     = module.gitlab_group_level_4.group_resources["aa/cc/dd/ee"].id != null
    error_message = "can not find group aa/cc/dd/ee"
  }
  assert {
    condition     = length(module.gitlab_group_level_5.group_resources) == 0
    error_message = "unexpected groups in level 5"
  }
}