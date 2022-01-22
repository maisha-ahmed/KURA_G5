resource "aws_ecs_service" "ei_service" {
  name                 = "${var.application_name}_service"
  cluster              = aws_ecs_cluster.ei_cluster.id
  task_definition      = aws_ecs_task_definition.ei_task_definition.arn
  desired_count        = var.app_count
  launch_type          = "FARGATE"
  force_new_deployment = true

  network_configuration {
    security_groups  = [aws_security_group.ei_ecs_sg.id]
    subnets          = [aws_subnet.public1.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.ei_target_group.id
    container_name   = "${var.application_name}-application"
    container_port   = var.app_port
  }

  depends_on = [aws_ecs_task_definition.ei_task_definition]
}


#Security Group for Development EC2 Instance
resource "aws_security_group" "ei_ecs_sg" {
  name        = "${var.application_name}_ecs_sg"
  description = "security group for ei ecs service"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "EI ECS Security Group"
  }
}

resource "aws_security_group_rule" "ei_ecs_ingress" {
  type              = "ingress"
  description       = "All inbound traffic"
  protocol          = "-1"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ei_ecs_sg.id
}

resource "aws_security_group_rule" "ei_ecs_egress" {
  type              = "egress"
  description       = "All outbound traffic"
  protocol          = "-1"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ei_ecs_sg.id
}