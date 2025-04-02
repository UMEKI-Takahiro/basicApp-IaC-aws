######################
# vpc
######################

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
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
resource "aws_subnet" "public_subnet_0" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "basicApp-public-subnet-0"
  }
}
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "basicApp-public-subnet-1"
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
resource "aws_route_table_association" "public_0_association" {
  subnet_id      = aws_subnet.public_subnet_0.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# security group for lb
resource "aws_security_group" "sg_for_lb" {
  name   = "sg_for_lb"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "sg-for-lb"
  }
}
resource "aws_security_group_rule" "sg_egress_rule_for_lb" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_for_lb.id
}
resource "aws_security_group_rule" "sg_ingress_rule_for_lb_http" {
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_for_lb.id
}
resource "aws_security_group_rule" "sg_ingress_rule_for_lb_https" {
  type              = "ingress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_for_lb.id
}

######################
# private
######################
# private route table for web and app
# It's needed for S3 Gateway endpoint
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "basicApp-private-route-table"
  }
}
# associate private subnet and route table
resource "aws_route_table_association" "private_for_web" {
  subnet_id      = aws_subnet.private_subnet_for_web.id
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_route_table_association" "private_for_app" {
  subnet_id      = aws_subnet.private_subnet_for_app.id
  route_table_id = aws_route_table.private_route_table.id
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
resource "aws_security_group_rule" "sg_ingress_rule_http_for_web" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/24"]
  security_group_id = aws_security_group.sg_for_web.id
}
resource "aws_security_group_rule" "sg_ingress_rule_https_for_web" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.sg_for_web.id
}
resource "aws_security_group_rule" "sg_ingress_rule_ssh_for_web" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/24"]
  security_group_id = aws_security_group.sg_for_web.id
}

# private subnet for app server
resource "aws_subnet" "private_subnet_for_app" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.32.0/24"
  availability_zone = "ap-northeast-1c"
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
resource "aws_security_group_rule" "sg_ingress_rule_http_for_app" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["10.0.16.0/24"]
  security_group_id = aws_security_group.sg_for_app.id
}
resource "aws_security_group_rule" "sg_ingress_rule_https_for_app" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.sg_for_app.id
}

# private subnet for db server
resource "aws_subnet" "private_subnet_for_db_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.48.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "basicApp-private-subnet-for-db-1"
  }
}
resource "aws_subnet" "private_subnet_for_db_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.49.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "basicApp-private-subnet-for-db-2"
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
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["10.0.32.0/24"]
  security_group_id = aws_security_group.sg_for_db.id
}

######################
# vpc endpoint
######################
# It's needed to pull image from ECR.

# ecr api endpoint
resource "aws_vpc_endpoint" "ecr_api_endpoint" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_subnet_for_web.id,
    aws_subnet.private_subnet_for_app.id,
  ]
  security_group_ids = [
    aws_security_group.sg_for_web.id,
    aws_security_group.sg_for_app.id,
  ]
  private_dns_enabled = true
  tags = {
    Name = "ecr-api-endpoint"
  }
}
# ecr dkr endpoint
resource "aws_vpc_endpoint" "ecr_dkr_endpoint" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_subnet_for_web.id,
    aws_subnet.private_subnet_for_app.id,
  ]
  security_group_ids = [
    aws_security_group.sg_for_web.id,
    aws_security_group.sg_for_app.id,
  ]
  tags = {
    Name = "ecr-dkr-endpoint"
  }
}
# s3 gateway endpoint
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    aws_route_table.private_route_table.id
  ]
  tags = {
    Name = "s3-endpoint"
  }
}

