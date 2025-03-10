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
# public
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
# private
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

# security group for web server
resource "aws_security_group" "sg_for_web" {
  name   = "sg_for_web"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "sg-for-web"
  }
}
resource "aws_security_group_rule" "sg_egress_rule_for_web" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_for_web.id
}
resource "aws_security_group_rule" "sg_ingress_rule_for_web" {
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/24"]
  security_group_id = aws_security_group.sg_for_web.id
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

# security group for app server
resource "aws_security_group" "sg_for_app" {
  name   = "sg_for_app"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "sg-for-app"
  }
}
resource "aws_security_group_rule" "sg_egress_rule_for_app" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_for_app.id
}
resource "aws_security_group_rule" "sg_ingress_rule_for_app" {
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["10.0.16.0/24"]
  security_group_id = aws_security_group.sg_for_app.id
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

# security group for db server
resource "aws_security_group" "sg_for_db" {
  name   = "sg_for_db"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "sg-for-db"
  }
}
resource "aws_security_group_rule" "sg_egress_rule_for_db" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_for_db.id
}
resource "aws_security_group_rule" "sg_ingress_rule_for_db" {
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["10.0.32.0/24"]
  security_group_id = aws_security_group.sg_for_db.id
}

