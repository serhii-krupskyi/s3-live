include {
  path = find_in_parent_folders()
}

terraform {
  source = "https://github.com/serhii-krupskyi/s3-live.git"
}

locals {
  # Automatically load environment-level variables
  environment_vars  = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_variables  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  account_variables = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  service_name = "velero"
  environment  = local.environment_vars.locals.environment
  aws_region   = local.region_variables.locals.aws_region

}

inputs = {
  remote_state_key            = "${local.environment}/${local.aws_region}/containers/eks/terraform.tfstate"
  aws_profile             = local.account_variables.locals.aws_profile
  aws_region             = local.aws_region
  terraform_bucket       = local.environment_vars.locals.terraform_bucket
  service_name           = local.service_name
  create_ses_policy      = "false"
  environment            = local.environment
  lifecycle_rule_enabled = true
  s3_policy_resources = [
    "arn:aws:s3:::quadro-${local.service_name}-${local.environment}",
  ]
  additional_tags = {
    Environment = title(local.environment)
  }
}
