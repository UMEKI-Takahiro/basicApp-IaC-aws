resource "aws_ecs_service" "ecs_service_app" {
  name                              = "ecs-service-app"
  cluster                           = aws_ecs_cluster.ecs_cluster.arn
  task_definition                   = aws_ecs_task_definition.app_ecs_task_definition.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  platform_version                  = "1.3.0"
  health_check_grace_period_seconds = 60
  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.sg_for_app.id]
    subnets = [
      aws_subnet.private_subnet_for_app.id
    ]
  }
  service_registries {
    registry_arn   = aws_service_discovery_service.asds.arn
    container_name = "app-server"
  }
  depends_on = [aws_service_discovery_service.asds]
  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_ecs_task_definition" "app_ecs_task_definition" {
  family                   = "app-ecs-task-definition"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.app_ecs_task_execution_role.arn
  container_definitions    = file("./container_definitions_app.json")
}

resource "aws_iam_role" "app_ecs_task_execution_role" {
  name = "appEcsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "app_ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.app_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

