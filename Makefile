.PHONY: deploy local tf_plan tf_deploy tf_init app_build app_run

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
	docker run -d -p 80:80 hello_world