# vpc
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "basicApp-vpc"
  }
}

# public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "basicApp-public-subnet"
  }
}

# private subnet for web server
resource "aws_subnet" "private_subnet_for_web" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.16.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "basicApp-private-subnet-for-web"
  }
}

# private subnet for app server
resource "aws_subnet" "private_subnet_for_app" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.32.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "basicApp-private-subnet-for-app"
  }
}

# private subnet for db server
resource "aws_subnet" "private_subnet_for_db" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.48.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "basicApp-private-subnet-for-db"
  }
}

# security policy

