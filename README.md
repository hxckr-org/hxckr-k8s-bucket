# hxckr Kubernetes Configuration

This repository contains the Kubernetes configuration files for the hxckr project. The application is split into multiple microservices, each with its own deployment and service configuration.

## Components

1. **Server** (`server.yaml`): Main application server handling CRUD operations and business logic.
2. **Git Auth Service** (`git-auth-service.yaml`): Handles authentication for Git operations.
3. **Softserve** (`softserve.yaml`): Manages in-progress code challenges and triggers webhooks. Exposed externally.
4. **Webhook Handler** (`webhook-handler.yaml`): Listens for webhook events and publishes tasks to job queues.
5. **Job Queue** (`job-queue.yaml`): RabbitMQ instance for managing tasks.
6. **Test Runners** (`test-runners.yaml`): JavaScript and Python test runners for executing code challenges.
7. **Git Service** (`git-service.yaml`): Interacts with Softserve git server, providing HTTP endpoints for git-related operations.

## Prerequisites

Before running the configuration, ensure you have the following:

1. A Kubernetes cluster set up and running
2. `kubectl` installed and configured to communicate with your cluster
3. Docker images for each component (or mock images for testing)

## Running the Configuration

Follow these steps to deploy the hxckr application:

1. Create a namespace for the application (optional but recommended):
   ```
   kubectl create namespace hxckr
   ```

2. Apply the configurations:
   ```
   kubectl apply -f server.yaml -f git-auth-service.yaml -f softserve.yaml -f webhook-handler.yaml -f job-queue.yaml -f test-runners.yaml -f git-service.yaml -n hxckr
   ```
   Or, if all files are in the current directory:
   ```
   kubectl apply -f . -n hxckr
   ```

3. Check the status of the deployments:
   ```
   kubectl get pods -n hxckr
   ```

4. Wait for all pods to be in the "Running" state.

5. To access the softserve service externally, get its LoadBalancer IP:
   ```
   kubectl get service softserve -n hxckr
   ```

6. Use the EXTERNAL-IP of the softserve service to access it externally.

## Internal Communication

The frontend hosted on Vercel will communicate with the server using the external IP or domain name of the server service. Make sure to configure the appropriate environment variables in your Vercel deployment to point to the correct server URL.

## Security Note

Only the softserve service is exposed externally. All other services, including the server, are internal to the cluster for security reasons. Ensure proper network policies are in place to restrict communication between services as needed.

## Cleaning Up

To remove all deployed resources:
```
kubectl delete -f . -n hxckr
```
