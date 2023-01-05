# **Terraform Development Environment**

This is purely a "learning and applying what I've learned in practice" project.

*(You can find the details about my learnings and objectives below the "important notes" section)*

### **Description:**
This Infrastructure as a Code (IaaC) project will deploy a small dev environment on AWS using Terraform. The deployed node (ubuntu 18.04) will be accesible via SSH and it will have Docker installed by default.

### **Usage:**
To quickly setup a node for Docker practice or testing, and also to release the resources when done working with it.


### **Important Notes:**
To use this code ideally you should have: the AWS SDK extension for VSC and the Terraform client installed. (The unofficial Terraform syntax checker extension for VSC is optional.)


Additionally edit the code the following way:
- In the providers.tf file at line 15 and 16: provide your own access and secret access key for the AWS Cloud.
- In the main.tf file at line 75 ("resource "aws_security_group" "botlane_sg" {)" provide your IP address(s) instead of the "???".

---------
### **Learnings and Details:**
This is purely a "learning and applying what I've learned in practice" project. The objectives and learnings were:

- Provision resources from AWS without using the AWS management console.    
*(Checking for example the owner of an AMI is allowed!)*
- How to configure a VSC Client to use the AWS SDK and Terraform
- How to define the basic points of the Terraform setup such as "provider.tf", "main.tf".
- Configure the network setup in a way that the node is only reachable by certain nodes on the internet and that the node can access anything. Also configuring:
    - VPC
    - Subnet
    - Internet Gateway
    - Route Table
    - Route and the Route Association
- Configuring the security aspect of the environment:
    - Security Group
    - Keypair for SSH
- Selecting an AMI and configuring an EC2 instance:
    - Also adding a userdata.tpl file to install Docker
- Adding some varibles based on the host_os system
- Defining a simple output (public IP) when the Terraform command has been ran

---------
### **Credits:**

Knowledge and guidance during my studies were used from:

- [For theoretical knowledge](https://app.pluralsight.com/library/courses/implementing-terraform-aws/table-of-contents)
- [For creating the project](https://youtu.be/iRaai1IBlB0)