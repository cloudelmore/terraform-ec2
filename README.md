# Terraform EC2 and S3 on AWS

A small Terraform project that builds an EC2 instance and an S3 bucket on AWS. The EC2 instance is created through a reusable module. I built this while learning Terraform, working from installing it through writing my own module.

## What It Builds

- **EC2 instance** running the latest Amazon Linux 2023 image, created through a reusable module in `modules/ec2`
- **S3 bucket** with Name and Environment tags
- **Outputs** that print the instance ID and public IP after each apply

Everything is deployed to `us-east-1`.

## Project Structure

```
terraform-ec2/
├── main.tf                 # Provider, module call, S3 bucket, outputs
├── .terraform.lock.hcl     # Locks the AWS provider version
├── .gitignore              # Keeps state files and plugins out of Git
└── modules/
    └── ec2/
        ├── main.tf         # AMI lookup and EC2 instance
        ├── variables.tf    # Module inputs
        └── outputs.tf      # Values passed back to the root config
```

## How the Module Works

The `modules/ec2` folder works like a function. It takes inputs, builds an instance, and returns results.

- **variables.tf** declares the inputs: `instance_type` (defaults to `t2.micro`) and `instance_name` (required).
- **main.tf** looks up the current Amazon Linux 2023 AMI and builds the instance using those inputs.
- **outputs.tf** returns the instance ID and public IP.

The root `main.tf` calls the module like this:

```hcl
module "ec2" {
  source        = "./modules/ec2"
  instance_type = "t2.micro"
  instance_name = "Week 5 Terraform-Module-Instance"
}
```

To create another instance, add a second module block with a different name and values. No EC2 code needs to be copied.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) 1.x
- [AWS CLI](https://aws.amazon.com/cli/) configured with `aws configure`, using an IAM user with permission to manage EC2 and S3
- An AWS account (the instance and bucket may incur small charges)

## Usage

1. Clone the repo and move into the project folder.
2. In `main.tf`, change the bucket name to something unique. S3 bucket names must be unique across all AWS accounts, so the name in this repo is already taken.
3. Run:

```bash
terraform init      # Downloads the AWS provider and registers the module
terraform plan      # Shows what will be created
terraform apply     # Builds the resources
```

4. When finished, remove everything so it stops costing money:

```bash
terraform destroy
```

## What's Not in This Repo

The `.gitignore` excludes:

- **`terraform.tfstate` and backups.** The state file records the real details of deployed resources, including account numbers, ARNs, and IP addresses. It should never be committed to a public repo. Teams usually store it remotely, such as in an S3 bucket.
- **`.terraform/`**, which holds the downloaded provider plugin. `terraform init` recreates it.

## Problems I Ran Into

**Outdated AMI ID.** The first version hardcoded an AMI ID that AWS had since retired, so the apply failed. I replaced it with a lookup of the AWS-managed SSM parameter for the latest Amazon Linux 2023 image, so the AMI stays current:

```hcl
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}
```

**Deprecated S3 ACL argument.** Setting `acl = "private"` on the bucket produced a deprecation warning. Current versions of the AWS provider manage bucket permissions through separate resources, and new buckets are private by default, so I removed the argument.

**Misleading bucket error.** Creating the bucket failed with a message saying the region `us-east-1` was wrong and AWS expected `ap-south-1`. The real cause was that another AWS account already owned a bucket with that name in `ap-south-1`. A more unique bucket name fixed it.

**Running plan from the wrong folder.** Running `terraform plan` inside `modules/ec2` prompted for `instance_name`, because Terraform treated the module as a standalone project with nothing supplying its variables. Running Terraform from the project root fixed it.

## What I Learned

- Writing infrastructure as code with providers, resources, and data sources
- The plan, apply, and destroy workflow, and how Terraform decides whether to update a resource in place or replace it
- Building a reusable module with inputs and outputs
- Why the state file matters and why it stays out of version control
