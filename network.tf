# vpc
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "basicApp-vpc"
  }
}

# public subnet

# private subnet

# security policy

