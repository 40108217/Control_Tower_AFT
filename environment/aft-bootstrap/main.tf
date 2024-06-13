provider "aws" {
  region 	= "us-east-1"
  shared_credentials_files = ["$HOME/.aws/config"]
  profile = "AWSAdministratorAccess-803408249084"
}
# To update to the latest version then replace below
module "aft_pipeline" {
  source = "git::https://github.com/aws-ia/terraform-aws-control_tower_account_factory.git?ref=1.3.1"
#  ...

#module "aft_pipeline"
#  source = "github.com/aws-ia/terraform-aws-control_tower_account_factory"
  # Required Variables
  ct_management_account_id                         = "803408249084"
  log_archive_account_id                           = "992382702023"
  audit_account_id                                 = "381492067005"
  aft_management_account_id                        = "730335566898"
  ct_home_region                                   = "us-east-1"
  tf_backend_secondary_region                      = "us-east-1"
  
  # Terraform variables
  #terraform_version                                = "1.6.5"
  terraform_version                                = "<4.0.0"
  terraform_distribution                           = "oss"
    
  # VCS variables
  vcs_provider                                     = "codecommit"

  # AFT Feature flags
  aft_feature_cloudtrail_data_events               = true
  aft_feature_enterprise_support                   = false
  aft_feature_delete_default_vpcs_enabled          = true
}
