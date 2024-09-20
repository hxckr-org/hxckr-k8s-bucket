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

1. A Kubernetes cluster set up and running
2. `kubectl` installed and configured to communicate with your cluster
3. Docker images for each component (or mock images for testing)

## Deployment Instructions

The hxckr application can be deployed in two environments: development and production. Each environment has its own configuration managed through Kustomize overlays.

### Development Deployment

To deploy the application in the development environment:

1. Ensure you're in the root directory of the project.

2. Apply the Kubernetes configurations:
   ```
   kubectl apply -k k8s/overlays/development
   ```

3. Verify the deployment:
   ```
   kubectl get pods -n hxckr-dev
   ```

4. Wait for all pods to be in the "Running" state.

5. To access the softserve service externally, get its LoadBalancer IP:
   ```
   kubectl get service softserve -n hxckr-dev
   ```

6. Use the EXTERNAL-IP of the softserve service to access it externally.

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
