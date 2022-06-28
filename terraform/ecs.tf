resource "aws_ecs_task_definition" "hello_world" {
  family = "hello_world"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions = jsonencode([
    {
      name      = "web"
      image     = "090893809397.dkr.ecr.eu-central-1.amazonaws.com/hello_world_cluster:latest"
      cpu       = 512
      memory    = 128
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  depends_on = [
    aws_iam_role.ecsTaskExecutionRole
  ]

  count = var.deploy_ecs ? 1 : 0
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = {
    Name = "hello_world_cluster"
  }

  inline_policy {
    policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
})
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.ecsTaskExecutionRole.name
}

resource "aws_ecs_cluster" "hello_world"{
  name = "hello_world"

  setting {
    name = "containerInsights"
    value = "enabled"
  }

  count = var.deploy_ecs ? 1 : 0
}

resource "aws_ecs_cluster_capacity_providers" "hello_world" {
  cluster_name = aws_ecs_cluster.hello_world[0].name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }

  count = var.deploy_ecs ? 1 : 0
}

resource "aws_security_group" "ecs" {
  name        = "hello_world"
  vpc_id      = aws_vpc.hello_world.id

  ingress {
    description      = "HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "hello_world"
  }
}

resource "aws_ecs_service" "hello_world" {
  name            = "hello_world"
  cluster         = aws_ecs_cluster.hello_world[0].id
  task_definition = aws_ecs_task_definition.hello_world[0].arn
  network_configuration {
    assign_public_ip = true
    subnets = [ aws_subnet.public_a.id, aws_subnet.public_b.id ]
    security_groups = [ aws_security_group.ecs.id ]
  }
  desired_count   = 1

  count = var.deploy_ecs ? 1 : 0
}