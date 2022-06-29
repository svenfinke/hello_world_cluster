terraform {
  backend "remote" {
    organization = "svenfinke-test"
 
    workspaces {
      name = "hello_world_cluster"
    }
  }
}