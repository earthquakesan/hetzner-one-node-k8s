ifeq ($(USE_DOT_ENV),true) 
	include .env
endif

include scripts/variables.sh

TF_DIR := deployment/terraform/cluster
TF_RUN=terraform -chdir=${TF_DIR}
TF_PLAN_FILE=apply.tfplan
TF_COMMON_ENV := ../../environment/common.tfvars

bootstrap:
	./scripts/create-az-storage.sh

clean:
	./scripts/remove-az-storage.sh

connect:
	./scripts/connect.sh

configure-local-env:
	./scripts/configure-local-env.sh

env:
	echo "The current git branch: $(shell git rev-parse --abbrev-ref HEAD)"
	echo "GIT_BRANCH is set to: ${GIT_BRANCH}"
	echo "TARGET_BRANCH is set to: ${TARGET_BRANCH}"
	echo "Running in the environment: ${ENV}"

tf-lint:
	$(TF_RUN) fmt -recursive

tf-init:
	$(TF_RUN) init -reconfigure \
		-backend-config="resource_group_name=${RG_NAME}" \
		-backend-config="storage_account_name=${STORAGE_ACCOUNT_NAME}" \
		-backend-config="container_name=${STORAGE_CONTAINER_NAME}" \
		-backend-config="key=main"

tf-plan-show:
	$(TF_RUN) show \
		-json \
		${TF_PLAN_FILE}

tf-plan: tf-init
	$(TF_RUN) plan \
		-var-file=${TF_COMMON_ENV} \
		-var 'server_name=k3s-main' \
		-out=${TF_PLAN_FILE}

tf-apply: tf-plan
	$(TF_RUN) apply ${TF_PLAN_FILE}

tf-destroy:
	$(TF_RUN) plan -destroy \
		-var-file=${TF_COMMON_ENV} \
		-var 'server_name=k3s-main' \
		-out=${TF_PLAN_FILE}
	$(TF_RUN) apply ${TF_PLAN_FILE}

tf-state-backup: tf-init
	$(TF_RUN) state pull > ${ENV}-state.bkp
