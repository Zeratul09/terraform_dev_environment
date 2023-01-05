#As a zeroth step, we specify our provider and add our access and secret access key (profile is optional but advised)


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = "eu-west-3"
  access_key = "????????????????????"
  secret_key = "????????????????????????????????????????"
  profile    = "vscode"
}

#Go to the main file to check the used resources or the datasources.tf to check the AMI.