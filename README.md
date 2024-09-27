# hxckr Kubernetes Configuration

This repository contains the Kubernetes configuration files for the hxckr project. The application is split into multiple microservices, each with its own deployment and service configuration.

## Components

1. **Server** (`server.yaml`): Main application server handling CRUD operations and business logic.
2. **Softserve** (`softserve.yaml`): Manages in-progress code challenges and triggers webhooks. Exposed externally.
3. **Webhook Handler** (`webhook-handler.yaml`): Listens for webhook events and publishes tasks to job queues.
4. **Job Queue** (`job-queue.yaml`): RabbitMQ instance for managing tasks.
5. **Test Runners** (`test-runners.yaml`): JavaScript and Python test runners for executing code challenges.
6. **Git Service** (`git-service.yaml`): Interacts with Softserve git server, providing HTTP endpoints for git-related operations.

## Prerequisites

Before running the configuration, ensure you have the following:

> All dependencies will be provided by nix via DevBox

1. A Kubernetes cluster set up and running
2. `kubectl` installed and configured to communicate with your cluster
3. Docker images for each component (or mock images for testing)
4. `make` installed on your system

## Setup DevBox

The DevBox is a development environment that provides all the necessary tools and dependencies for the project. It uses Nix to manage the environment and ensure consistency across different systems.

To set up the DevBox:

```bash
curl -fsSL https://get.jetify.com/devbox | bash
```

## Deployment Instructions

The hxckr application can be deployed in two environments: development and production. Each environment has its own configuration managed through Kustomize overlays.

Before running the deployment commands ensure your devbox environment is setup and running

> Initialising the devbox environment in the repo root folder

```bash
  devbox shell
```

> Start minikube within devbox before starting the deployment

```bash
  minikube start
```

### Using the Makefile

We provide a Makefile to simplify common operations. Here are the available commands:

- `make dev-deploy`: Deploy the application in the development environment(takes few seconds to complete)
- `make dev-verify`: Verify the deployment in the development environment
- `make dev-softserve`: Get the external IP of the softserve service in development
- `make dev-clean`: Remove all deployed resources in the development environment

To start individual services:

- `make dev-start-server`: Start the server service
- `make dev-start-softserve`: Start the softserve service
- `make dev-start-webhook-handler`: Start the webhook handler service
- `make dev-start-job-queue`: Start the job queue service
- `make dev-start-test-runners`: Start the test runners service
- `make dev-start-git-service`: Start the git service

For a full list of available commands, run `make help`.

### Development Deployment

To deploy the application in the development environment:

1. Ensure you're in the root directory of the project.

2. Run the deployment command:
   ```
   make dev-deploy
   ```

3. Verify the deployment:
   ```
   make dev-verify
   ```

4. Wait for all pods to be in the "Running" state.

5. To access the server and softserve service externally,
    ```bash
     minikube service server -n hxckr-dev
    ```
    > and for softserve
    ```bash
     minikube service softserve -n hxckr-dev
    ```
6. Use the URL of the server and softserve service to access it externally.

### Production Deployment

Before deploying to production, ensure that the necessary secrets are created:

1. Database Secret:
   a. Obtain the DATABASE_URL from your Railway dashboard.
   b. Create the secret in your Kubernetes cluster:
      ```
      kubectl create secret generic db-secrets \
        --from-literal=db-url='your-actual-railway-database-url' \
        --namespace hxckr-prod
      ```
      Replace 'your-actual-railway-database-url' with the actual URL from Railway.

2. RabbitMQ Secret:
   a. Choose a secure username and password for RabbitMQ.
   b. Create the secret in your Kubernetes cluster:
      ```
      kubectl create secret generic rabbitmq-secret \
        --from-literal=username='your-rabbitmq-username' \
        --from-literal=password='your-rabbitmq-password' \
        --namespace hxckr-prod
      ```
      Replace 'your-rabbitmq-username' and 'your-rabbitmq-password' with your chosen credentials.

3. Apply the Kubernetes configurations:
   ```
   kubectl apply -k k8s/overlays/production
   ```

4. Verify the deployment:
   ```
   kubectl get pods -n hxckr-prod
   ```

5. Wait for all pods to be in the "Running" state.

6. To access the softserve service externally, get its LoadBalancer IP:
   ```
   kubectl get service softserve -n hxckr-prod
   ```

7. Use the EXTERNAL-IP of the softserve service to access it externally.

Note: Ensure that both the db-secrets and rabbitmq-secret secrets are created before applying the Kubernetes configurations in production.

### Updating Production Database URL

The db-secrets secret is created manually and persists across deployments. You only need to create it once unless you need to update the database URL. To update the secret:

1. Delete the existing secret:
   ```
   kubectl delete secret db-secrets -n hxckr-prod
   ```

2. Recreate the secret with the new URL:
   ```
   kubectl create secret generic db-secrets \
     --from-literal=db-url='your-new-railway-database-url' \
     --namespace hxckr-prod
   ```

3. Restart the deployments to pick up the new secret:
   ```
   kubectl rollout restart deployment server -n hxckr-prod
   ```

### Updating Production Secrets

The db-secrets and rabbitmq-secret are created manually and persist across deployments. You only need to create them once unless you need to update the values. To update a secret:

1. Delete the existing secret:
   ```
   kubectl delete secret <secret-name> -n hxckr-prod
   ```
   Replace <secret-name> with either db-secrets or rabbitmq-secret.

2. Recreate the secret with the new values using the appropriate command from steps 1 or 2 in the "Production Deployment" section.

3. Restart the affected deployments to pick up the new secret:
   ```
   kubectl rollout restart deployment <deployment-name> -n hxckr-prod
   ```
   Replace <deployment-name> with the name of the deployment using the updated secret (e.g., server, job-queue).

### Ingress Configuration

The application uses an Ingress resource to manage external access to the services in the cluster. The Ingress is configured to route traffic to the server service.

1. Ensure your domain's DNS is configured to point to your cluster's ingress controller's external IP.

2. Update the Ingress configuration in `k8s/overlays/production/ingress.yaml` with your domain:

   ```yaml
   spec:
     tls:
     - hosts:
       - your-domain.com
     rules:
     - host: your-domain.com
   ```

   Replace `your-domain.com` with your actual domain.

### TLS Certificate Setup

The production environment uses cert-manager to automatically provision and manage TLS certificates. The cert-manager ClusterIssuer is included in the Kubernetes configuration and will be applied automatically when you deploy to production.

1. Ensure your domain's DNS is configured to point to your cluster's ingress controller's external IP.

2. The Ingress resource in the production overlay is already configured to use the ClusterIssuer. When you deploy, cert-manager will automatically request and configure the TLS certificate for your domain.

After making these changes, proceed with the production deployment steps. The Ingress will be created with TLS enabled, and cert-manager will provision a valid certificate for your domain.

## Cleaning Up

To remove all deployed resources:

For development:
```
kubectl delete -f . -n hxckr-dev
```

For production:
```
kubectl delete -f . -n hxckr-prod
```
