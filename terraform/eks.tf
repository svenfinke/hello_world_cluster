
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
  count = var.deploy_eks ? 1 : 0
  
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
  count = var.deploy_eks ? 1 : 0
}

resource "aws_iam_role_policy_attachment" "hello_world-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker.name
  count = var.deploy_eks ? 1 : 0
}

resource "aws_iam_role_policy_attachment" "hello_world-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker.name
  count = var.deploy_eks ? 1 : 0
}

resource "aws_eks_node_group" "hello_world"{
  cluster_name = aws_eks_cluster.hello_world[0].name
  node_group_name = "hello_world_cluster"
  node_role_arn = aws_iam_role.worker.arn
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  instance_types = [ "t4g.small" ]
  ami_type = "AL2_ARM_64"
  count = var.deploy_eks ? 1 : 0

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