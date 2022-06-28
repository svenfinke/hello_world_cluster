# k8s
deploy:
	./scripts/deploy.sh

# TERRAFORM
tf_plan:
	cd terraform && terraform plan
tf_deploy:
	cd terraform && terraform apply
tf_init:
	cd terraform && terraform init

# APP
app_build:
	docker build ./app -t hw_test
app_run:
	docker run -d hw_test