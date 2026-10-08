# Look up the latest Amazon Linux 2023 AMI
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# EC2 instance built from the values passed into the module
resource "aws_instance" "this" {
  ami           = data.aws_ssm_parameter.al2023.value
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}