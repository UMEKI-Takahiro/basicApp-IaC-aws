resource "aws_ecs_service" "ecs_service_web" {
  name                              = "ecs-service-web"
  cluster                           = aws_ecs_cluster.ecs_cluster.arn
  task_definition                   = aws_ecs_task_definition.web_ecs_task_definition.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  platform_version                  = "1.3.0"
  health_check_grace_period_seconds = 60
  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.sg_for_web.id]
    subnets = [
      aws_subnet.private_subnet_for_web.id
    ]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    container_name   = "web-server"
    container_port   = 80
  }
  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_ecs_task_definition" "web_ecs_task_definition" {
  family                   = "web-ecs-task-definition"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./web_container_definitions.json")
}

