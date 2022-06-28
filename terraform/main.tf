resource "aws_ecr_repository" "hello_world" {
  name                 = "hello_world_cluster"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}