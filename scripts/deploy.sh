ACCOUNT=090893809397
REGION=eu-central-1
TAG=poc
IMAGE=hello_world_cluster

# Login to push to ECR
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 090893809397.dkr.ecr.eu-central-1.amazonaws.com
aws eks --region eu-central-1 update-kubeconfig --name hello_world

# Build & push image
docker build -t 090893809397.dkr.ecr.eu-central-1.amazonaws.com/hello_world_cluster:poc app/ 
docker tag 090893809397.dkr.ecr.eu-central-1.amazonaws.com/hello_world_cluster:poc 090893809397.dkr.ecr.eu-central-1.amazonaws.com/hello_world_cluster:latest
docker push 090893809397.dkr.ecr.eu-central-1.amazonaws.com/hello_world_cluster:poc

# Deploy
kubectl apply -f k8s/deployment.yaml
kubectl rollout restart deployment/hello-world-deployment