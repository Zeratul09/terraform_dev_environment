#A few important notes when you write a terraform file:
#While technically this is the main file, you still need to specify a provider.tf in the same folder as the main file. Also you should add a datasources.tf file when it comes to provisioning some instances.
#For the provider, you will need to add the Access key and Secret Access key either as a file or hardcoded into the code. (For the purpose of this project it's hardcoded)


#Install the AWS SDK for VSC and a Terraform syntax checker.
#Make sure that you stick to a specific naming convention.
#Always try to autofill to avoid typos.
#Check the code espcially where you put "=" signs.
#Tags are always optional, but nevertheless a useful addition to the code.
#You can check the state of your current resources by switching to the SDK tab and under resources expand the list.
#If you can see it, simply add it from the command palette.
#Some useful terraform commands:
# "terraform init": The first command you should run before you start working with terraform. (Make sure that terraform package is installed on your PC)
# "terraform apply": Sets up the currently specified resources in the environment (you may yuse -auto-approve for convenience sake)
# "terraform destroy": Removes your complete enviornment (options need to be specified)
# "terraform plan": Outputs the resources that you will add to the environment.
# "terraform fmt": Formats your terraform code, making it more "pleasant" to look at (For example: It lines up all the equal signs in one resource)

#First, we create a VPC with some settings such as, CIDR block defined and DNS hostnames and DNS support enabled:
resource "aws_vpc" "botlane_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "botlane_dev"
  }
}

#Second, we create a public subnet, making sure we specify the AZ correctly:
resource "aws_subnet" "botlane_public_subnet" {
  vpc_id                  = aws_vpc.botlane_vpc.id
  cidr_block              = "10.123.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-3a"

  tags = {
    Name = "botlane_dev_public"
  }
}

#Third, we add an internet gateway (IGW) to our setup:
resource "aws_internet_gateway" "botlane_internet_gateway" {
  vpc_id = aws_vpc.botlane_vpc.id

  tags = {
    Name = "botlane_dev_igw"
  }
}

#Fourth, we specify a route table:
resource "aws_route_table" "botlane_public_rt" {
  vpc_id = aws_vpc.botlane_vpc.id

  tags = {
    Name = "botlane_dev_public_rt"
  }
}

#Fifth, we setup our routing using our previously create route table ID (RT) and internet gateway (IGW) ID:
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.botlane_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.botlane_internet_gateway.id
}

#Sixth, now we add a Route Table Association (RTA or Assoc) for our setup:
resource "aws_route_table_association" "botlane_public_association" {
  subnet_id      = aws_subnet.botlane_public_subnet.id
  route_table_id = aws_route_table.botlane_public_rt.id
}

#Seventh, now we will add a security group: (Keep in mind when you specify the cidr block that you give your ip address.)
resource "aws_security_group" "botlane_sg" {
  name        = "botlane_sg"
  description = "botlane security group"
  vpc_id      = aws_vpc.botlane_vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    #Add your own IP addresses here instead of the "???" signs:
    cidr_blocks = ["???.???.???.???/32", "???.???.???.???/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#For complateness sake, while this next part is specified in datasources.tf but...
  #Eigth, we specify an AMI (Amazon Machine Image)
  #Ninth, we will create a keypair and a terraform resource that utilizes this keypair. It's better to change the path where the key will be saved to:
  #ssh-keygen -t ed25519       (You can change key encryption type to RSA if you want, but we will use ed25519 in this one)
  #Maybe rename the name of the key just in case.
  #Then run "ls ~/.ssh" (It just shows us the directory)

#Tenth, we will use the recently created keypair:
#The file command is how we read the file.

resource "aws_key_pair" "botlane_auth" {
  key_name   = "botlanekey"
  public_key = file("~/.ssh/botlanekey.pub")
}

resource "aws_instance" "dev_node" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.botlane_server_ami.id
  #You can run here the terraform state show aws_key_pair.botlane_auth so you can use the keyname instead of the .id
  key_name               = aws_key_pair.botlane_auth.id
  vpc_security_group_ids = [aws_security_group.botlane_sg.id]
  subnet_id              = aws_subnet.botlane_public_subnet.id
  #We are extracting the template that we've defined from template.tpl.
  user_data = file("userdata.tpl")

  tags = {
    Name = "dev_node"
  }

  #Allocated drive size:
  root_block_device {
    volume_size = 10
  }

  #Thirnteeth we specify first specify an ssh config as a template and use it in a Provisioner (this should not be used for every deployment) We simply we are adding info to a config file into our a local terminal.
  #Provisioners are always being run in a local resource and also "terraform plan" won't detect them.
  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/botlanekey"
    })
    interpreter = var.host_os == "windows" ? ["powershell", "-command"] : ["bash", "-c"]
    #interpreter = ["bash", "-c"] - for Linux
    #Go down for step fourteen
  }
}

#Starting from this line we will have to jump back to the code above and to some different files such as outputs.tf or variables.tf

#Eleventh, we will specify a template in userdata.tpl
#Twelveth, after running terraform apply we will connect to our node.
#By using first terraform state list, locate our instance, and then running terraform state show "resource" copy the public IP.
#Finally, run ssh -i "path to our generated auth key" ubuntu@"IPADDRESS" (Run this twice, as it could be that first time you would get "Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
#Warning: Permanently added '???.???.???.???' (ED25519) to the list of known hosts."
#Finally, being on the host you can start running for example docker commands: docker --version
#(Go up for step Thirteen)


#As step fourteen, you might want to replace your infrastructure with terraform apply
#Then, replace the dev_node (with terraform state list, copy the dev_node one) and check for changes with "terraform apply -replace aws_instance.dev_node"
#When your dev node is up, check if the config file has been applied example: cat ~/.ssh/config
#Let's check our node by ssh-ing into it.

#The fifteenth Optimize our script by adding variables:

#At the provisioner we will change the OS name
#command = templatefile("windows-ssh-config.tpl", {  -> #command = templatefile("${var.host_os-ssh-config.tpl", {

#The sixteenth step: Adding some conditionals (check the provisioner section)
#The seventeeth step: Outputs.