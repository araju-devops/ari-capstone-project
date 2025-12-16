Phase 1: Architectural Strategy & Preparation
The core change is shifting from a pure Kubernetes deployment (as seen in your ASSIGNMENT_REQUIREMENTS.md) to a Hybrid Azure Cloud Architecture.

Old Architecture (File): React, Node Backends, and Postgres DB all inside one Kubernetes cluster.

New Architecture (Prompt):

Frontend: Azure App Service (PaaS)

Backend: Azure Kubernetes Service (AKS)

Database: Azure Database for PostgreSQL (PaaS)

Gateway: Azure API Management (APIM)

Action Step: You must decouple your codebase. The prompt suggests separating repositories.

Create Repository 1 (capstone-ui): Move the frontend folder content to the root of this repo.

Create Repository 2 (capstone-api): Move backend-a, backend-b, db, and k8s folders here.

Phase 2: Infrastructure as Code (Terraform)
You need to write Terraform scripts to provision resources for Dev, QA, and Prod.

Step 2.1: Directory Structure Create a terraform/ directory with subfolders for environments or use workspaces. A modular approach is best:

Plaintext

terraform/
├── modules/
│   ├── networking/ (VNet, Subnets)
│   ├── database/   (Azure Database for PostgreSQL)
│   ├── aks/        (Azure Kubernetes Service)
│   ├── webapp/     (Azure App Service for Frontend)
│   └── apim/       (API Management)
├── environments/
│   ├── dev/
│   ├── qa/
│   └── prod/
Step 2.2: Define Resources (Key Configurations)

Resource Groups: Create rg-capstone-dev, rg-capstone-qa, rg-capstone-prod.

Database (PaaS): Provision azurerm_postgresql_server.

Critical: Enable "Allow Access to Azure Services" so AKS can talk to it.

Create the database capstone_db inside the server.

AKS Cluster: Provision azurerm_kubernetes_cluster.

App Service: Provision azurerm_service_plan (Linux) and azurerm_linux_web_app for the UI.

APIM: Provision azurerm_api_management.

Phase 3: Codebase Modifications
The provided code was designed for internal K8s communication. You must adapt it for the Azure components.

A. Database (PaaS Migration)
Action: You no longer need k8s/05-postgres-statefulset.yaml or k8s/postgres-service.yaml. The DB is now external.

Initialization: The db/init.sql script needs to be run against the Azure PostgreSQL instance once created. You can do this via a GitHub Actions step using psql or a one-time Kubernetes Job.

B. Frontend (React + Nginx Config)
Current Issue: Your frontend/nginx.conf proxies requests to http://backend-a-service:8080. This URL will not exist inside the App Service environment because the backend is now in a separate AKS cluster.

Solution: Configure the Frontend to talk to API Management (APIM).

Modify frontend/src/App.js: Change the getApiUrl function to use an environment variable.

JavaScript

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || ''; 

const getApiUrl = (target) => {
  // If API_BASE_URL is set (e.g., https://my-apim.azure-api.net), use it.
  // Otherwise fall back to relative path (dev mode)
  return `${API_BASE_URL}/api/${target}`;
};
Update frontend/Dockerfile: React environment variables must be present at build time.

Dockerfile

# In the build stage
ARG REACT_APP_API_BASE_URL
ENV REACT_APP_API_BASE_URL=$REACT_APP_API_BASE_URL
RUN npm run build
Deploying: When building your Docker image for Dev/QA/Prod, pass the specific APIM URL for that environment as a build argument.

C. Backend (AKS)
Modify K8s Manifests:

Update k8s/07-backend-a-deployment.yaml & 08:

The environment variables DB_HOST, DB_USER, etc., currently pull from ConfigMaps/Secrets.

Action: Update the db-config ConfigMap and db-secret Secret in your pipeline (using kubectl create secret ...) to point to the Azure PostgreSQL PaaS credentials, not the internal K8s service.

Expose Services:

Your backend-a-service.yaml is likely ClusterIP. To allow APIM to reach it, you generally need an Ingress Controller (like Nginx Ingress) or change the service to LoadBalancer (easier for beginners, but less secure).

Recommendation: Install Nginx Ingress Controller on AKS. Create an Ingress resource that routes traffic to backend-a-service and backend-b-service.

Security: Ensure APIM is the only allowed caller (using VNet integration or IP restrictions on the Ingress).

Phase 4: Pipeline Setup (CI/CD)
Create two separate pipelines (e.g., GitHub Actions or Azure DevOps).

Pipeline 1: Backend (AKS)
Trigger: On commit to capstone-api.

Build:

Build Docker images for backend-a and backend-b.

Push to Azure Container Registry (ACR).

Deploy (Dev/QA/Prod):

Login to Azure (az login).

Get AKS credentials (az aks get-credentials).

Create Secrets: Inject the Azure PostgreSQL connection strings into Kubernetes Secrets.

Apply Manifests: kubectl apply -f k8s/backend-a-deployment.yaml, k8s/service.yaml, etc.

Pipeline 2: Frontend (App Service)
Trigger: On commit to capstone-ui.

Build:

Build the Docker image using the frontend/Dockerfile.

Crucial: Pass the environment-specific APIM URL as a build arg: docker build --build-arg REACT_APP_API_BASE_URL=https://dev-apim.azure-api.net ...

Push to ACR.

Deploy:

Update the Azure App Service to pull the new image from ACR.

Phase 5: API Management (APIM) Configuration
Create APIs: In Azure Portal (or Terraform), create two APIs: backend-a and backend-b.

Backend Target: Point these APIs to the Public IP of your AKS Load Balancer/Ingress Controller.

Policies (CORS): Since your React UI (on App Service) and API (on APIM) are on different domains, you must enable CORS in APIM.

XML

<cors allow-credentials="true">
    <allowed-origins>
        <origin>https://your-dev-frontend.azurewebsites.net</origin>
    </allowed-origins>
    <allowed-methods>
        <method>GET</method>
        <method>POST</method>
    </allowed-methods>
</cors>
Summary Checklist
[ ] Terraform: Create 3 RGs, 3 Postgres DBs, 3 AKS clusters, 3 App Services, 1 APIM (or 3 if separating completely).

[ ] Repo: Split UI and API code.

[ ] React: Update App.js to use REACT_APP_API_BASE_URL.

[ ] Docker: Update Frontend Dockerfile to accept build arguments.

[ ] K8s: Remove DB StatefulSets; Update ConfigMaps to point to Azure PaaS DB.

[ ] Pipelines: Create separate build/deploy pipelines for UI and API.

[ ] APIM: Configure routing to AKS and enable CORS.
