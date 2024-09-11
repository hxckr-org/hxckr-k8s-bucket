# hxckr Kubernetes Configuration

This repository contains the Kubernetes configuration files for the hxckr project. The application is split into multiple microservices, each with its own deployment and service configuration.

## Components

1. **Server** (`server.yaml`): Main application server handling CRUD operations and business logic.
2. **Frontend** (`frontend.yaml`): User interface for the application. Exposed externally. Communicates internally with the server.
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
   kubectl apply -f server.yaml -f frontend.yaml -f softserve.yaml -f webhook-handler.yaml -f job-queue.yaml -f test-runners.yaml -f git-service.yaml -n hxckr
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

5. To access the frontend and softserve services externally, get their LoadBalancer IPs:
   ```
   kubectl get service frontend softserve -n hxckr
   ```

6. Use the EXTERNAL-IP of the frontend service to access the application in your web browser.

## Internal Communication

The frontend communicates with the server using the internal Kubernetes DNS. The server's URL is passed to the frontend as an environment variable `SERVER_URL`.

## Security Note

Only the frontend and softserve services are exposed externally. All other services, including the server, are internal to the cluster for security reasons. Ensure proper network policies are in place to restrict communication between services as needed.

## Cleaning Up

To remove all deployed resources:
```
kubectl delete -f . -n hxckr
```
