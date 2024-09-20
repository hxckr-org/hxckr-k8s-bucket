# Makefile for hxckr Kubernetes Configuration

# Variables
KUBECTL := kubectl
DEV_NAMESPACE := hxckr-dev
PROD_NAMESPACE := hxckr-prod

# Development tasks
.PHONY: dev-deploy dev-verify dev-softserve dev-clean dev-create-namespace dev-destroy-namespace

dev-deploy:
	$(KUBECTL) apply -k k8s/overlays/development

dev-verify:
	$(KUBECTL) get pods -n $(DEV_NAMESPACE)

dev-softserve:
	$(KUBECTL) get service softserve -n $(DEV_NAMESPACE)

dev-clean:
	$(KUBECTL) delete -k k8s/overlays/development

dev-create-namespace:
	$(KUBECTL) apply -f k8s/overlays/development/namespace.yaml

dev-destroy-namespace:
	$(KUBECTL) delete namespace $(DEV_NAMESPACE)

# Individual service tasks
.PHONY: dev-start-server dev-start-softserve dev-start-webhook-handler dev-start-job-queue dev-start-test-runners dev-start-git-service

dev-start-server: dev-create-namespace
	$(KUBECTL) apply -k k8s/overlays/development --prune -l app=server

dev-start-softserve: dev-create-namespace
	$(KUBECTL) apply -k k8s/overlays/development --prune -l app=softserve

dev-start-webhook-handler: dev-create-namespace
	$(KUBECTL) apply -k k8s/overlays/development --prune -l app=webhook-handler

dev-start-job-queue: dev-create-namespace
	$(KUBECTL) create configmap rabbitmq-definitions --from-file=k8s/overlays/development/definitions.json -n $(DEV_NAMESPACE) --dry-run=client -o yaml | $(KUBECTL) apply -f -
	$(KUBECTL) apply -f k8s/base/job-queue.yaml -n $(DEV_NAMESPACE)

dev-start-test-runners: dev-create-namespace
	$(KUBECTL) apply -k k8s/overlays/development --prune -l app=test-runners

dev-start-git-service: dev-create-namespace
	$(KUBECTL) apply -k k8s/overlays/development --prune -l app=git-service

# Production tasks
.PHONY: prod-deploy prod-verify prod-softserve prod-clean

prod-deploy:
	$(KUBECTL) apply -k k8s/overlays/production

prod-verify:
	$(KUBECTL) get pods -n $(PROD_NAMESPACE)

prod-softserve:
	$(KUBECTL) get service softserve -n $(PROD_NAMESPACE)

prod-clean:
	$(KUBECTL) delete -k k8s/overlays/production

# Log fetching tasks
.PHONY: dev-logs prod-logs dev-logs-server dev-logs-softserve dev-logs-webhook-handler dev-logs-job-queue dev-logs-test-runners dev-logs-git-service

dev-logs:
	$(KUBECTL) logs -n $(DEV_NAMESPACE) --all-containers=true --since=1h -l app

prod-logs:
	$(KUBECTL) logs -n $(PROD_NAMESPACE) --all-containers=true --since=1h -l app

dev-logs-server:
	$(KUBECTL) logs -n $(DEV_NAMESPACE) --all-containers=true --since=1h -l app=server

dev-logs-softserve:
	$(KUBECTL) logs -n $(DEV_NAMESPACE) --all-containers=true --since=1h -l app=softserve

dev-logs-webhook-handler:
	$(KUBECTL) logs -n $(DEV_NAMESPACE) --all-containers=true --since=1h -l app=webhook-handler

dev-logs-job-queue:
	$(KUBECTL) logs -n $(DEV_NAMESPACE) --all-containers=true --since=1h -l app=job-queue

dev-logs-test-runners:
	$(KUBECTL) logs -n $(DEV_NAMESPACE) --all-containers=true --since=1h -l app=test-runners

dev-logs-git-service:
	$(KUBECTL) logs -n $(DEV_NAMESPACE) --all-containers=true --since=1h -l app=git-service

# Helper tasks
.PHONY: help

help:
	@echo "Available tasks:"
	@echo "Development tasks:"
	@echo "  dev-deploy              - Deploy the application in the development environment"
	@echo "  dev-verify              - Verify the deployment in the development environment"
	@echo "  dev-softserve           - Get the external IP of the softserve service in development"
	@echo "  dev-clean               - Remove all deployed resources in the development environment"
	@echo "  dev-create-namespace    - Create the development namespace"
	@echo "  dev-destroy-namespace   - Destroy the development namespace"
	@echo "  dev-start-server        - Start the server service in development"
	@echo "  dev-start-softserve     - Start the softserve service in development"
	@echo "  dev-start-webhook-handler - Start the webhook handler service in development"
	@echo "  dev-start-job-queue     - Start the job queue service in development"
	@echo "  dev-start-test-runners  - Start the test runners service in development"
	@echo "  dev-start-git-service   - Start the git service in development"
	@echo "  dev-logs               - Fetch logs for all pods in the development environment"
	@echo "  dev-logs-server        - Fetch logs for the server service in development"
	@echo "  dev-logs-softserve     - Fetch logs for the softserve service in development"
	@echo "  dev-logs-webhook-handler - Fetch logs for the webhook handler service in development"
	@echo "  dev-logs-job-queue     - Fetch logs for the job queue service in development"
	@echo "  dev-logs-test-runners  - Fetch logs for the test runners service in development"
	@echo "  dev-logs-git-service   - Fetch logs for the git service in development"
	@echo "Production tasks:"
	@echo "  prod-deploy             - Deploy the application in the production environment"
	@echo "  prod-verify             - Verify the deployment in the production environment"
	@echo "  prod-softserve          - Get the external IP of the softserve service in production"
	@echo "  prod-clean              - Remove all deployed resources in the production environment"
	@echo "  prod-logs              - Fetch logs for all pods in the production environment"
	@echo "  help                    - Display this help message"