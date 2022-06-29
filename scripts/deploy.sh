#!/bin/bash

# Login to push to ECR
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 090893809397.dkr.ecr.eu-central-1.amazonaws.com

# Build & push image
if [[ $OSTYPE == 'darwin'* ]]; then
  docker buildx create --use
  docker buildx build --platform linux/amd64,linux/arm64 --push -t 090893809397.dkr.ecr.eu-central-1.amazonaws.com/hello_world_cluster:latest app/ 
else
  docker build --push -t 090893809397.dkr.ecr.eu-central-1.amazonaws.com/hello_world_cluster:latest app/ 
fi

# Deploy k8s
aws eks --region eu-central-1 update-kubeconfig --name hello_world
kubectl apply -f k8s/deployment.yaml
kubectl rollout restart deployment/hello-world-deployment