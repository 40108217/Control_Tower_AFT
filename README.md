# Control_Tower_AFT

Workshop : https://catalog.workshops.aws/control-tower/en-US/customization/aft/workflow

For SSO config on CLI access(On Local Laptop)

https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html
$ aws configure sso
SSO session name (Recommended): my-sso
SSO start URL [None]: https://my-sso-portal.awsapps.com/start
SSO region [None]: us-east-1
SSO registration scopes [None]: sso:account:access 
The AWS CLI attempts to open your default browser and begin the login process for your IAM Identity Center account.
Attempting to automatically open the SSO authorization page in your default browser.  If the AWS CLI cannot open the browser, the following message appears with instructions on how to manually start the login process. If the browser does not open or you wish to use a different device to authorize this request, open the following URL:
https://device.sso.us-west-2.amazonaws.com/
Then enter the code:
 QCFK-N451 //whatever random code is generated

To refresh the session token(On Local Laptop)
aws sso login --sso-session veru-test-1

Need to create 2 profile
	1. For CT Management 
	2. For AFT Management 

From your terminal, execute the command below to share the portfolio with AWSAFTExecution IAM role.(To be executed in ControlTower Management Account)
sudo yum install jq -y
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=us-east-1
export ACCOUNT_FACTORY_PORTFOLIO=`aws servicecatalog list-portfolios --region $AWS_REGION | jq -r '.PortfolioDetails[] | select (.DisplayName | contains("AWS Control Tower Account Factory Portfolio")) | .Id'`
AWSAFTEXECUTION_ROLE="arn:aws:iam::${ACCOUNT_ID}:role/AWSAFTExecution"
aws servicecatalog associate-principal-with-portfolio --portfolio-id $ACCOUNT_FACTORY_PORTFOLIO --principal-arn $AWSAFTEXECUTION_ROLE --principal-type IAM --region $AWS_REGION

Confirm that the portfolio is shared successfully by running command below.(To be executed in ControlTower Management Account)
aws servicecatalog list-principals-for-portfolio --portfolio-id $ACCOUNT_FACTORY_PORTFOLIO --region $AWS_REGION | jq -r '.Principals[] | .PrincipalARN' | grep AWSAFTExecution -q && echo "Portfolio shared to AWSAFTExecution" || echo "Portfolio not shared properly"

Account Customizations(To be executed in AFT Management Account)
From your IDE, run the command below to copy example account customization
cd ~/environment/
AWS_REGION=us-east-1
AFT_ACCOUNT_CUSTOMIZATIONS_REPO=`aws ssm get-parameter --name /aft/config/account-customizations/repo-name --region $AWS_REGION | jq -r ".Parameter.Value"`
AFT_ACCOUNT_CUSTOMIZATIONS_BRANCH=`aws ssm get-parameter --name /aft/config/account-customizations/repo-branch --region $AWS_REGION | jq -r ".Parameter.Value"`
AFT_ACCOUNT_CUSTOMIZATIONS_HTTP=`aws codecommit get-repository --repository-name $AFT_ACCOUNT_CUSTOMIZATIONS_REPO --region $AWS_REGION | jq -r ".repositoryMetadata.cloneUrlHttp"`
git clone --branch $AFT_ACCOUNT_CUSTOMIZATIONS_REPO https://github.com/aws-samples/aft-workshop-sample $AFT_ACCOUNT_CUSTOMIZATIONS_REPO
cd $AFT_ACCOUNT_CUSTOMIZATIONS_REPO
rm -rf .git
git init
git remote add origin $AFT_ACCOUNT_CUSTOMIZATIONS_HTTP
git add .
git commit -m 'first commit'
git branch -m $AFT_ACCOUNT_CUSTOMIZATIONS_BRANCH
git push --set-upstream origin $AFT_ACCOUNT_CUSTOMIZATIONS_BRANCH

From your IDE, navigate to the aft-account-customizations directory. Examine the repo folder structure
aft-account-customizations/
├── PRODUCTION
│   ├── api_helpers
│   │   ├── post-api-helpers.sh
│   │   ├── pre-api-helpers.sh
│   │   └── python
│   │       └── requirements.txt
│   └── terraform
│       ├── aft-providers.jinja
│       ├── backend.jinja
│       └── main.tf
└── SANDBOX
    ├── api_helpers
    │   ├── post-api-helpers.sh
    │   ├── pre-api-helpers.sh
    │   └── python
    │       └── requirements.txt
    └── terraform
        ├── aft-providers.jinja
        ├── backend.jinja
        └── main.tf
Example : S3 Block Public Access at Account level
cd ~/environment/
AWS_REGION=us-east-1
AFT_GLOBAL_CUSTOMIZATIONS_REPO=`aws ssm get-parameter --name /aft/config/global-customizations/repo-name --region $AWS_REGION | jq -r ".Parameter.Value"`
AFT_GLOBAL_CUSTOMIZATIONS_BRANCH=`aws ssm get-parameter --name /aft/config/global-customizations/repo-branch --region $AWS_REGION | jq -r ".Parameter.Value"`
AFT_GLOBAL_CUSTOMIZATIONS_HTTP=`aws codecommit get-repository --repository-name $AFT_GLOBAL_CUSTOMIZATIONS_REPO --region $AWS_REGION | jq -r ".repositoryMetadata.cloneUrlHttp"`
git clone --branch $AFT_GLOBAL_CUSTOMIZATIONS_REPO https://github.com/aws-samples/aft-workshop-sample $AFT_GLOBAL_CUSTOMIZATIONS_REPO
cd $AFT_GLOBAL_CUSTOMIZATIONS_REPO
rm -rf .git
git init
git remote add origin $AFT_GLOBAL_CUSTOMIZATIONS_HTTP
git add .
git commit -m 'first commit'
git branch -m $AFT_GLOBAL_CUSTOMIZATIONS_BRANCH
git push --set-upstream origin $AFT_GLOBAL_CUSTOMIZATIONS_BRANCH

On this lab, we will use a basic state machine that perform pass operations to demonstrate the functionality. Future lab will cover provisioning customizations in detail.
cd ~/environment/
AWS_REGION=us-east-1
AFT_PROVISIONING_CUSTOMIZATIONS_REPO=`aws ssm get-parameter --name /aft/config/account-provisioning-customizations/repo-name --region $AWS_REGION | jq -r ".Parameter.Value"`
AFT_PROVISIONING_CUSTOMIZATIONS_BRANCH=`aws ssm get-parameter --name /aft/config/account-provisioning-customizations/repo-branch --region $AWS_REGION | jq -r ".Parameter.Value"`
AFT_PROVISIONING_CUSTOMIZATIONS_HTTP=`aws codecommit get-repository --repository-name $AFT_PROVISIONING_CUSTOMIZATIONS_REPO --region $AWS_REGION | jq -r ".repositoryMetadata.cloneUrlHttp"`
git clone --branch $AFT_PROVISIONING_CUSTOMIZATIONS_REPO https://github.com/aws-samples/aft-workshop-sample $AFT_PROVISIONING_CUSTOMIZATIONS_REPO
cd $AFT_PROVISIONING_CUSTOMIZATIONS_REPO
rm -rf .git
git init
git remote add origin $AFT_PROVISIONING_CUSTOMIZATIONS_HTTP
git add .
git commit -m 'first commit'
git branch -m $AFT_PROVISIONING_CUSTOMIZATIONS_BRANCH
git push --set-upstream origin $AFT_PROVISIONING_CUSTOMIZATIONS_BRANCH

Account Requests
To create and update AWS account using AFT, you use the aft-account-request Terraform module. You need to provide mandatory input such as account root email address and the organizational unit (OU). Each time you add or modify account request, the Terraform file is commited to the repository and it will trigger the AFT pipeline
cd ~/environment/
AWS_REGION=us-east-1
AFT_ACCOUNT_REQUEST_REPO=`aws ssm get-parameter --name /aft/config/account-request/repo-name --region $AWS_REGION | jq -r ".Parameter.Value"`
AFT_ACCOUNT_REQUEST_BRANCH=`aws ssm get-parameter --name /aft/config/account-request/repo-branch --region $AWS_REGION | jq -r ".Parameter.Value"`
AFT_ACCOUNT_REQUEST_HTTP=`aws codecommit get-repository --repository-name $AFT_ACCOUNT_REQUEST_REPO --region $AWS_REGION | jq -r ".repositoryMetadata.cloneUrlHttp"`
git clone --branch $AFT_ACCOUNT_REQUEST_REPO https://github.com/aws-samples/aft-workshop-sample $AFT_ACCOUNT_REQUEST_REPO
cd $AFT_ACCOUNT_REQUEST_REPO
rm -rf .git
git init
git remote add origin $AFT_ACCOUNT_REQUEST_HTTP
git add .
git commit -m 'first commit'
git branch -m $AFT_ACCOUNT_REQUEST_BRANCH
git push --set-upstream origin $AFT_ACCOUNT_REQUEST_BRANCH

Provision an Account
Let's submit a new account request. We will use vending account email address that you supplied as part of the pre-requisites on part 1.
1. Login to your AFT Management account using AWS SSO role with Administrator access.
2. From your IDE, navigate to the aft-account-request/terraform directory.
3. Create a new file, give it a name account-requests.tf
4. Add the Terraform code below. Change the placeholder {{PLACEHOLDER NAME}} with your own value, for example for account email, name, OU and SSO. Be sure to set account_customizations_name with either PRODUCTION or SANDBOX. Feel free to modify other values such as tags and custom fields.
module "account_request_01" {
  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail              = "{{ACCOUNT EMAIL}}"
    AccountName               = "{{ACCOUNT NAME}}"
    ManagedOrganizationalUnit = "{{OU NAME}} ({{OU ID}})" 
    SSOUserEmail              = "{{ACCOUNT SSO EMAIL}}"
    SSOUserFirstName          = "{{ACCOUNT SSO FIRST NAME}}"
    SSOUserLastName           = "{{ACCOUNT SSO LAST NAME}}"
  }

  account_tags = {
    "ABC:Owner"       = "myname@mycompany.com"
    "ABC:Division"    = "ENT"
    "ABC:Environment" = "Dev"
    "ABC:CostCenter"  = "123456"
    "ABC:Vended"      = "true"
    "ABC:DivCode"     = "102"
    "ABC:BUCode"      = "ABC003"
    "ABC:Project"     = "123456"
  }

  change_management_parameters = {
    change_requested_by = "AWS Control Tower Lab"
    change_reason       = "Learn AWS Control Tower Account Factory for Terraform (AFT)"
  }

  custom_fields = {
    custom1 = "a"
    custom2 = "b"
  }

  account_customizations_name = "SANDBOX"
}

Save the file and run code below to commit to the repository to create the account as update in Module "account_request_01"
cd ~/environment/
AWS_REGION=us-east-1
AFT_ACCOUNT_REQUEST_REPO=$(aws ssm get-parameter --name /aft/config/account-request/repo-name --region $AWS_REGION | jq -r ".Parameter.Value")
AFT_ACCOUNT_REQUEST_BRANCH=$(aws ssm get-parameter --name /aft/config/account-request/repo-branch --region $AWS_REGION | jq -r ".Parameter.Value")
cd /Users/virendra.singh/Downloads/CT_AFT/environment/$AFT_ACCOUNT_REQUEST_REPO
git add .
git commit -m 'Veru first account request'
git push origin $AFT_ACCOUNT_REQUEST_BRANCH

Import previously created Account
cd ~/environment/

AWS_REGION=us-east-1
AFT_ACCOUNT_REQUEST_REPO=$(aws ssm get-parameter --name /aft/config/account-request/repo-name --region $AWS_REGION | jq -r ".Parameter.Value")
AFT_ACCOUNT_REQUEST_BRANCH=$(aws ssm get-parameter --name /aft/config/account-request/repo-branch --region $AWS_REGION | jq -r ".Parameter.Value")

cd /Users/virendra.singh/Downloads/CT_AFT/environment/$AFT_ACCOUNT_REQUEST_REPO
git add .
git commit -m 'Audit account first account import request'
git push origin $AFT_ACCOUNT_REQUEST_BRANCH

To allow AFT to update and manage other AWS accounts alternate contacts
1. Login to your AWS Control Tower Management account using AWS SSO role with Administrator access.
2. Open your CloudShell  .
Enter command below to delegate the AFT Management account as the administrator to manage alternate contacts. Replace {{AFT-MANAGEMENT-ACCOUNT}} with your AFT Management account id.
aws organizations enable-aws-service-access --service-principal account.amazonaws.com
aws organizations register-delegated-administrator --account-id 730335566898 --service-principal account.amazonaws.com 
Implement a Customizations
1. Login to your AFT Management account using AWS SSO role with Administrator access.
2. Run commands below to import the aft-alternate-contacts module.

cd ~/environment/
AWS_REGION=us-east-1
AFT_PROVISIONING_CUSTOMIZATIONS_REPO=`aws ssm get-parameter --name /aft/config/account-provisioning-customizations/repo-name --region $AWS_REGION | jq -r ".Parameter.Value"`
AFT_PROVISIONING_CUSTOMIZATIONS_BRANCH=`aws ssm get-parameter --name /aft/config/account-provisioning-customizations/repo-branch --region $AWS_REGION | jq -r ".Parameter.Value"`
mkdir ./$AFT_PROVISIONING_CUSTOMIZATIONS_REPO/terraform/modules/
git clone --branch aft-alternate-contacts https://github.com/aws-samples/aft-workshop-sample aft-alternate-contacts
rm -rf aft-alternate-contacts/.git
mv ./aft-alternate-contacts ./$AFT_PROVISIONING_CUSTOMIZATIONS_REPO/terraform/modules/
cd /Users/virendra.singh/Downloads/CT_AFT/environment/$AFT_PROVISIONING_CUSTOMIZATIONS_REPO/terraform/modules/aft-alternate-contacts/lambda/aft_alternate_contacts_validate
make build
make clean
cd /Users/virendra.singh/Downloads/CT_AFT/environment/$AFT_PROVISIONING_CUSTOMIZATIONS_REPO/
touch ./terraform/main.tf
touch ./terraform/data.tf

Open the main.tf file under terraform directory. Add the code below to the file to launch the module. Don't forget to replace placeholder for {{CT-MANAGEMENT-ACCOUNT}} with your AWS Control Tower Management account id and {{CT-ORGANIZATIONS-ID}} with your AWS Org id

module "alternate-contacts" {
  source = "./modules/aft-alternate-contacts"
  aws_ct_mgt_account_id = "803408249084"
  aws_ct_mgt_org_id = "o-bzte7hbcs0"
 }

Open the data.tf file under terraform directory and add code below to the file
data "aws_region" "aft_management_region" {}
data "aws_caller_identity" "aft_management_id" {}

Replace the content on file customizations.asl.json under terraform/states with code below. Dont forget to save it.
{
  "StartAt": "Pass",
  "States": {
    "Pass": {
      "Type": "Pass",
      "Next": "aft-alternate-contacts-step"
    },
    "aft-alternate-contacts-step": {
      "Type": "Task",
      "Resource": "arn:aws:states:::states:startExecution.sync:2",
      "Parameters": {
        "StateMachineArn": "${data_aft_alternate_contacts_state}",
        "Input.$": "$"
      },
      "End": true
    }
  }
}

Open file states.tf under terraform directory. Replace the file content with the following code.
resource "aws_sfn_state_machine" "aft_account_provisioning_customizations" {
  name       = "aft-account-provisioning-customizations"
  role_arn   = aws_iam_role.aft_states.arn
  definition = templatefile("${path.module}/states/customizations.asl.json", {
    data_aft_alternate_contacts_state = module.alternate-contacts.aft_alternate_contacts_state_machine_arn
  })
  depends_on = [
    aws_iam_role_policy.aft_states
  ]
}


Open file iam-aft-states.tpl under terraform/iam/role-policies directory. Replace the file content with the following code

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "states:Start*",
            "Resource": [
                "${alternate_contacts_customizations_sfn_arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "events:PutTargets",
                "events:PutRule",
                "events:DescribeRule"
            ],
            "Resource": [
                "arn:aws:events:${data_aws_region}:${data_aws_account_id}:rule/StepFunctionsGetEventsForStepFunctionsExecutionRule"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "states:DescribeExecution",
                "states:StopExecution"
            ],
            "Resource": "*"
        }
    ]
}

Open file iam.tf under terraform directory and replace the content with the following code
resource "aws_iam_role" "aft_states" {
  name               = "aft-account-provisioning-customizations-role"
  assume_role_policy = templatefile("${path.module}/iam/trust-policies/states.tpl", { none = "none" })
}

resource "aws_iam_role_policy" "aft_states" {
  name = "aft-account-provisioning-customizations-policy"
  role = aws_iam_role.aft_states.id

  policy = templatefile("${path.module}/iam/role-policies/iam-aft-states.tpl", {
    data_aws_region                             = data.aws_region.aft_management_region.name
    data_aws_account_id                         = data.aws_caller_identity.aft_management_id.account_id
    alternate_contacts_customizations_sfn_arn   = module.alternate-contacts.aft_alternate_contacts_state_machine_arn
  })
}

Save all files. Commit to the repository and push it to the pipeline to deploy the new state machine
git add .
git commit -m 'setup aft-alternate-contacts'
git push origin $AFT_ACCOUNT_CUSTOMIZATIONS_BRANCH

Validate the Customization
1. Login to your AFT Management account using AWS SSO role with Administrator access.
2. From your IDE, navigate to the aft-account-request/terraform directory.
3. Open your existing account-requests.tf file (or if you use different file name for account request, use that file)
4. From your existing account request, add alternate_contact section to the custom_fields parameter. Use reference below as example and modify it accordingly:
module "account_request_01" {
  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail              = "virendra.singh+aft1@hcl.com"
    AccountName               = "aft-test-1"
    ManagedOrganizationalUnit = "application (ou-2wvl-kpmf2ggx)" 
    SSOUserEmail              = "virendra.singh+1@hcl.com"
    SSOUserFirstName          = "Virendra"
    SSOUserLastName           = "Singh"
  }

  account_tags = {
    "VERU:Owner"       = "virendra.singh@hcl.com"
    "VERU:Division"    = "ENT"
    "VERU:Environment" = "Dev"
    "VERU:CostCenter"  = "123456"
    "VERU:Vended"      = "true"
    "VERU:DivCode"     = "102"
    "VERU:BUCode"      = "ABC003"
    "VERU:Project"     = "78910"
  }

  change_management_parameters = {
    change_requested_by = "AWS Control Tower Lab"
    change_reason       = "Learn AWS Control Tower Account Factory for Terraform (AFT)"
  }

  custom_fields = {
    alternate_contact = jsonencode(
      {
        "billing"= {
          "email-address" = "billing@mycompany.com",
          "name"          = "Account Receivable",
          "phone-number"  = "+11234567890",
          "title"         = "Billing Department"
        },
        "operations"= {
          "email-address" = "ops@mycompany.com",
          "name"          = "Operations 24/7",
          "phone-number"  = "+11234567890",
          "title"         = "DevOps Team"
        },
        "security"= {
          "email-address" = "soc@mycompany.com",
          "name"          = "Security Ops Center",
          "phone-number"  = "+11234567890",
          "title"         = "SOC Team"
        }
      }
    ),
    custom1 = "a",
    custom2 = "b"
  }

  account_customizations_name = "SANDBOX"
}

module "import_account_request_01" {
  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail              = "virendra.singh+Audit@hcl.com"
    AccountName               = "Audit"
    ManagedOrganizationalUnit = "Security (ou-2wvl-vilw516v)" 
    SSOUserEmail              = "virendra.singh+1@hcl.com"
    SSOUserFirstName          = "Virendra"
    SSOUserLastName           = "Singh"
  }
  account_tags = {
    "VERU:Owner"       = "virendra.singh@hcl.com"
    "VERU:Division"    = "ENT"
    "VERU:Environment" = "Dev"
    "VERU:CostCenter"  = "1234567"
    "VERU:Vended"      = "true"
    "VERU:DivCode"     = "103"
    "VERU:BUCode"      = "ABC003"
    "VERU:Project"     = "778910"
  }
  change_management_parameters = {
    change_requested_by = "AWS Control Tower Account Import"
    change_reason       = "Learn AWS Control Tower Account Factory for Terraform (AFT) Import Account"
  }
}


6. Save the file and run code below to commit to the repository.
cd ~/environment/
AWS_REGION=us-east-1
AFT_ACCOUNT_REQUEST_REPO=`aws ssm get-parameter --name /aft/config/account-request/repo-name --region $AWS_REGION | jq -r ".Parameter.Value"`
AFT_ACCOUNT_REQUEST_BRANCH=`aws ssm get-parameter --name /aft/config/account-request/repo-branch --region $AWS_REGION | jq -r ".Parameter.Value"`
cd /Users/virendra.singh/Downloads/CT_AFT/environment/$AFT_ACCOUNT_REQUEST_REPO
git add . 
git commit -m 'add alternate contacts' 
git push origin $AFT_ACCOUNT_REQUEST_BRANCH


Clean Up
Decommission the aft-alternate-contacts
To decommission this customization, do the following:
1. From your Cloud9, navigate to the aft-account-provisioning-customizations repository. Expand the terraform directory.
2. Delete the modules directory.
3. Delete both main.tf and data.tf.

Warning
steps below assumes you have default aft-account-provisioning-customizations without any customization.
4. Update states.tf file with its original content.
resource "aws_sfn_state_machine" "aft_account_provisioning_customizations" {
  name       = "aft-account-provisioning-customizations"
  role_arn   = aws_iam_role.aft_states.arn
  definition = templatefile("${path.module}/states/customizations.asl.json", {
  })
}

5. Update iam.tf file with its original content.
resource "aws_iam_role" "aft_states" {
  name               = "aft-account-provisioning-customizations-role"
  assume_role_policy = templatefile("${path.module}/iam/trust-policies/states.tpl", { none = "none" })
}

resource "aws_iam_role_policy" "aft_states" {
  name = "aft-account-provisioning-customizations-policy"
  role = aws_iam_role.aft_states.id

  policy = templatefile("${path.module}/iam/role-policies/iam-aft-states.tpl", {
    account_provisioning_customizations_sfn_arn = aws_sfn_state_machine.aft_account_provisioning_customizations.arn
  })
}

6. Update iam/role-policies/iam-aft-states.tpl file with its original content.
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "states:Start*",
            "Resource": "${account_provisioning_customizations_sfn_arn}"
        }
    ]
}

7. Update states/customizations.asl.json file with its original content.
{
    "StartAt": "Pass",
    "States": {
      "Pass": {
        "Type": "Pass",
        "End": true
      }
    }
}

8. Commit to the repository to revert the changes.
9. Login to the target AWS account that you use for the test earlier. Update the alternate contacts to it's original value. Use this instruction   as additional guide.
Remove account vended from AFT
1. Please refer to documentation on how to remove account from AFT 
2. Note that removing account from AFT does not automatically decomission it from AWS Control. Use the following documentation to unmanage account from AWS Control Tower 
Destroy AFT pipeline
1. To remove AFT, login to your AWS Control Tower Management account and use the Cloud9 that you provisioned on Lab 1.
2. Run terraform destroy to remove the AFT pipeline.
Destroy Cloud9 in AFT Management account
1. Return to your CloudShell in AFT Management account
2. Run terraform destroy under aft-cloud9 workspace
Destroy Cloud9 in AWS Control Tower Management account

Important
Do this only after AFT has been removed succesfully.
1. Return to your CloudShell in AWS CT Management account
2. Run terraform destroy under aft-cloud9 workspace

![image](https://github.com/40108217/Control_Tower_AFT/assets/59229710/38a6e272-297d-4bb3-98a8-d8cdec5cfb84)
