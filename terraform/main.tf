resource "aws_vpc" "hello_world" {
  cidr_block = "10.16.0.0/16"

  tags = {
    Name = "hello_world_cluster"
  }
}

resource "aws_internet_gateway" "hello_world" {
  vpc_id = aws_vpc.hello_world.id

  tags = {
    Name = "hello_world_cluster"
  }
}

resource "aws_route_table" "hello_world" {
  vpc_id = aws_vpc.hello_world.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hello_world.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.hello_world.id
  }

  depends_on = [
    aws_internet_gateway.hello_world
  ]

  tags = {
    Name = "hello_world_cluster"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id     = aws_vpc.hello_world.id
  cidr_block = cidrsubnet(aws_vpc.hello_world.cidr_block, 4, 5)
  availability_zone = "eu-central-1a"

  tags = {
    Name = "hello_world_cluster"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id     = aws_vpc.hello_world.id
  cidr_block = cidrsubnet(aws_vpc.hello_world.cidr_block, 4, 6)
  availability_zone = "eu-central-1b"

  tags = {
    Name = "hello_world_cluster"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id     = aws_vpc.hello_world.id
  cidr_block = cidrsubnet(aws_vpc.hello_world.cidr_block, 4, 10)
  availability_zone = "eu-central-1a"

  tags = {
    Name = "hello_world_cluster"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id     = aws_vpc.hello_world.id
  cidr_block = cidrsubnet(aws_vpc.hello_world.cidr_block, 4, 11)
  availability_zone = "eu-central-1b"

  tags = {
    Name = "hello_world_cluster"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.hello_world.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.hello_world.id
}

resource "aws_eip" "public_a_nat" {}
resource "aws_eip" "public_b_nat" {}

resource "aws_nat_gateway" "public_a" {
  allocation_id = aws_eip.public_a_nat.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "hello_world_cluster"
  }
}

resource "aws_nat_gateway" "public_b" {
  allocation_id = aws_eip.public_b_nat.id
  subnet_id     = aws_subnet.public_b.id

  tags = {
    Name = "hello_world_cluster"
  }
}

resource "aws_route_table" "hello_world_nat_a" {
  vpc_id = aws_vpc.hello_world.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.public_a.id
  }

  depends_on = [
    aws_nat_gateway.public_a
  ]

  tags = {
    Name = "hello_world_cluster"
  }
}

resource "aws_route_table" "hello_world_nat_b" {
  vpc_id = aws_vpc.hello_world.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.public_b.id
  }

  depends_on = [
    aws_nat_gateway.public_b
  ]

  tags = {
    Name = "hello_world_cluster"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.hello_world_nat_a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.hello_world_nat_b.id
}

resource "aws_ecr_repository" "hello_world" {
  name                 = "hello_world_cluster"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "hello_world" {
  name = "hello_world_cluster"

  tags = {
    Name = "hello_world_cluster"
  }
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "hello_world-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.hello_world.name
}

resource "aws_iam_role_policy_attachment" "hello_world-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.hello_world.name
}

resource "aws_eks_cluster" "hello_world" {
  name     = "hello_world"
  role_arn = aws_iam_role.hello_world.arn
  
  vpc_config {
    subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  }

  tags = {
    Name = "hello_world_cluster"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.hello_world-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.hello_world-AmazonEKSVPCResourceController,
  ]
}

resource "aws_iam_role" "worker" {
  name = "hello_world_cluster_worker_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = {
    Name = "hello_world_cluster"
  }
}

resource "aws_iam_role_policy_attachment" "hello_world-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "hello_world-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "hello_world-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker.name
}

resource "aws_eks_node_group" "hello_world"{
  cluster_name = aws_eks_cluster.hello_world.name
  node_group_name = "hello_world_cluster"
  node_role_arn = aws_iam_role.worker.arn
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  instance_types = [ "t4g.small" ]
  ami_type = "AL2_ARM_64"

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = {
    Name = "hello_world_cluster"
  }

  depends_on = [
    aws_iam_role.worker
  ]
}