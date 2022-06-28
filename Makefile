# k8s
deploy:
	./scripts/deploy.sh
local: app_build app_run

# TERRAFORM
tf_plan:
	cd terraform && terraform plan
tf_deploy:
	cd terraform && terraform apply
tf_init:
	cd terraform && terraform init

# LOCAL
app_build:
	docker build ./app -t hello_world
app_run:
	docker run -d hello_world