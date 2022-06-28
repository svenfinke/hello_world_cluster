# Hello World Cluster

A little demo project to deploy a little hello-world application into EKS and/or ECS Fargate.

# Usage

You can run the app locally by running `make local`. The rollout of the infrastructure can be done with `make tf_deploy`, this will create an EKS and an ECS cluster, depending on the variables set in the variables.tf or what you pass into terraform. The ECS Cluster will utilize Fargate.
To build and push the images and the kubernetes deployments and the kubernetes service, run `make deploy`. You will have to adjust the account-id in `scripts/deploy.sh` according to your AWS Account and region as that will change the name of your ECR.

# Improvements

## App

- Make it do something
- Add complexity if necessary (e.g. di-container, interfaces, classes, complex patterns)
- Add Tests (unit tests, integration tests and maybe even e2e tests)

## Terraform

- **Add a backend for the state!!**
- Move redundant code into modules
- Add configuration options through variables
- Seperate into multiple logical stacks (infra, auth, app)

## Deployment

- Add a pipeline
- Run tests from the app and add linting and checks for terraform

And there is a lot more to improve, but in the end it really depends on what you want to run and what your requirements are.