##############################
# キーペアの登録（両サーバーで同じキーを利用）
##############################
resource "aws_key_pair" "basic_app_ecr_test" {
  key_name   = "basic-app-ecr-test"
  public_key = file("~/.ssh/basic_app_ecr_test.pub")
}

##############################
# 踏み台サーバー用セキュリティグループ
##############################
resource "aws_security_group" "sg_for_bastion" {
  name        = "sg_for_bastion"
  description = "Security group for Bastion host"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

##############################
# ECR 接続テスト用サーバーの IAM ロール／インスタンスプロファイル
# ※ AmazonECSTaskExecutionRolePolicy をアタッチ
##############################
resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2-ecr-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_task_execution_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile-for-ecr"
  role = aws_iam_role.ec2_instance_role.name
}

##############################
# AWS AMI の取得（Amazon Linux 2）
##############################
data "aws_ami" "amazon_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

##############################
# 踏み台サーバー（Bastion Host）の作成（パブリックサブネット）
##############################
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet_0.id
  vpc_security_group_ids      = [aws_security_group.sg_for_bastion.id]
  key_name                    = aws_key_pair.basic_app_ecr_test.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y tmux htop
  EOF

  tags = {
    Name = "Bastion-Host"
  }
}

##############################
# ECR 接続テスト用サーバーの作成（プライベートサブネット）
##############################
resource "aws_instance" "ec2_test_instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet_for_web.id
  vpc_security_group_ids = [aws_security_group.sg_for_web.id]
  key_name               = aws_key_pair.basic_app_ecr_test.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y
    systemctl start docker
    usermod -aG docker ec2-user
  EOF

  tags = {
    Name = "ECR-Test-EC2-Instance"
  }
}

