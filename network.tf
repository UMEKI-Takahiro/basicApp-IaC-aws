######################
# vpc
######################

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "basicApp-vpc"
  }
}

######################
# internet gateway
######################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "basicApp-igw"
  }
}

######################
# public subnet
######################

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

# route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "basicApp-public-route-table"
  }
}

# associate public subnet and route table
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

######################
# private subnet
######################

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

