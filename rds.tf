resource "aws_db_subnet_group" "db_subnet_group" {
  name = "main"
  subnet_ids = [
    aws_subnet.private_subnet_for_db_1.id,
    aws_subnet.private_subnet_for_db_2.id,
  ]
  tags = {
    Name = "basicApp-db-subnet-group"
  }
}

resource "aws_db_instance" "basic-app-db" {
  identifier                 = "basic-app-db"
  engine                     = "mysql"
  engine_version             = "8.0"
  instance_class             = "db.t3.micro"
  allocated_storage          = 20
  storage_type               = "gp2"
  username                   = "basicappuser"     # Tentative
  password                   = "basicapppassword" # Tentative
  multi_az                   = false
  publicly_accessible        = false
  backup_retention_period    = 0
  auto_minor_version_upgrade = true
  deletion_protection        = false
  skip_final_snapshot        = true
  port                       = 3306
  vpc_security_group_ids     = [aws_security_group.sg_for_db.id]
  parameter_group_name       = "default.mysql8.0"
  db_subnet_group_name       = aws_db_subnet_group.db_subnet_group.name
  lifecycle {
    ignore_changes = [password]
  }
}

