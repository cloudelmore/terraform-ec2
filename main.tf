# main.tf

# Specify the provider (AWS)
provider "aws" {
  region = "us-east-1"
}

# Create an EC2 instance using the reusable module
module "ec2" {
  source        = "./modules/ec2"
  instance_type = "t2.micro"
  instance_name = "Week 5 Terraform-Module-Instance"
}

# Create an S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "jelmore-week5-tf-20261004"

  tags = {
    Name        = "Week_5_Bucket"
    Environment = "Dev"
  }
}

# Show the module's outputs after apply
output "ec2_instance_id" {
  value = module.ec2.instance_id
}

output "ec2_public_ip" {
  value = module.ec2.public_ip
}