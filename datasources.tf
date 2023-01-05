#First, in this new file we specify the AMI (Amazon Machine Image) that we wish to use for this you will have to provide, what is the owner ID of the AMI:
#Filter for "name" and the value which is technically the exact specification of the AMI. The asterisk "*" is important as it will filter for basically any date. (You can compare this to the AMI name in the Management Console)
#Make sure you don't miss a single dash "-" when writing in the name value of the AMI
data "aws_ami" "botlane_server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}