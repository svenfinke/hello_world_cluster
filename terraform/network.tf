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