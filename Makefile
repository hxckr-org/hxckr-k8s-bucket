# Makefile for hxckr Kubernetes Configuration

# Variables
KUBECTL := kubectl
DEV_NAMESPACE := hxckr-dev
PROD_NAMESPACE := hxckr-prod

# Development tasks
.PHONY: dev-deploy dev-verify dev-softserve dev-clean

dev-deploy:
	$(KUBECTL) apply -k k8s/overlays/development

dev-verify:
	$(KUBECTL) get pods -n $(DEV_NAMESPACE)

dev-softserve:
	$(KUBECTL) get service softserve -n $(DEV_NAMESPACE)

dev-clean:
	$(KUBECTL) delete -k k8s/overlays/development

# Individual service tasks
.PHONY: dev-start-server dev-start-softserve dev-start-webhook-handler dev-start-job-queue dev-start-test-runners dev-start-git-service

dev-start-server:
	$(KUBECTL) apply -f k8s/base/server.yaml -n $(DEV_NAMESPACE)

dev-start-softserve:
	$(KUBECTL) apply -f k8s/base/softserve.yaml -n $(DEV_NAMESPACE)

dev-start-webhook-handler:
	$(KUBECTL) apply -f k8s/base/webhook-handler.yaml -n $(DEV_NAMESPACE)

dev-start-job-queue:
	$(KUBECTL) apply -f k8s/base/job-queue.yaml -n $(DEV_NAMESPACE)

dev-start-test-runners:
	$(KUBECTL) apply -f k8s/base/test-runners.yaml -n $(DEV_NAMESPACE)

dev-start-git-service:
	$(KUBECTL) apply -f k8s/base/git-service.yaml -n $(DEV_NAMESPACE)

# Helper tasks
.PHONY: help

help:
	@echo "Available tasks:"
	@echo "  dev-deploy              - Deploy the application in the development environment"
	@echo "  dev-verify              - Verify the deployment in the development environment"
	@echo "  dev-softserve           - Get the external IP of the softserve service in development"
	@echo "  dev-clean               - Remove all deployed resources in the development environment"
	@echo "  dev-start-server        - Start the server service in development"
	@echo "  dev-start-softserve     - Start the softserve service in development"
	@echo "  dev-start-webhook-handler - Start the webhook handler service in development"
	@echo "  dev-start-job-queue     - Start the job queue service in development"
	@echo "  dev-start-test-runners  - Start the test runners service in development"
	@echo "  dev-start-git-service   - Start the git service in development"
	@echo "  help                    - Display this help message"