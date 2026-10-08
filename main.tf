
# main.tf

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}


# Specify the provider (AWS)
provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

# Create an EC2 instance
resource "aws_instance" "Week_5_EC2" {
 ami = data.aws_ssm_parameter.al2023.value
  instance_type = "t2.small"

  tags = {
    Name = "Week 5 Terraform-Example-Instance"
  }
}


# Create an S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "jelmore-week5-tf-20261004"

  tags = {
    Name        = "Week_5_Bucket"
    Environment = "Dev"}
}