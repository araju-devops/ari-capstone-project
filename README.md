# ARI Capstone Project - Multi-Backend Image Upload

Azure-based microservices application with Kubernetes orchestration, featuring a React frontend, dual backend services, and API Management gateway.

## 🏗️ Architecture

```
Frontend (React)  →  APIM Gateway  →  AKS Kubernetes Cluster
                                       ├─ Backend A (Node.js + PostgreSQL)
                                       └─ Backend B (Node.js + PostgreSQL)
```

## 📁 Project Structure

```
ari-capstone-project/
├── capstone-api/           # Backend API pipeline configuration
│   └── backend-pipeline.yml
├── capstone-ui/            # React frontend application
│   ├── src/
│   ├── public/
│   ├── Dockerfile
│   └── frontend-pipeline.yml
├── terraform/              # Infrastructure as Code
│   ├── main.tf
│   ├── modules/
│   │   ├── infra/         # Azure infrastructure (AKS, ACR, APIM, etc.)
│   │   └── k8s-addons/    # Kubernetes add-ons (ArgoCD, monitoring)
│   ├── environments/
│   │   ├── dev/
│   │   ├── qa/
│   │   └── prod/
│   └── terraform-pipeline.yml
├── apim-policies/          # API Management policy XML files
│   └── apim/
├── scripts/               # Utility scripts
│   ├── fix-apim-*.ps1
│   └── fix-apim-policy.py
└── docs/                  # Documentation
    ├── BACKEND_PIPELINE_STAGES.md
    ├── BACKEND_PIPELINE_SUMMARY.md
    └── FRONTEND_UI_SETUP_COMPLETE.md
```

## 🚀 Quick Start

### Prerequisites
- Azure subscription
- Azure CLI installed
- Terraform installed
- kubectl installed
- Docker installed
- Node.js 18+ (for local frontend development)

### Deploy Infrastructure
```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

### Deploy Backend Services
Azure DevOps pipeline: `Backend_Repo` → `backend-pipeline.yml`

### Deploy Frontend UI
Azure DevOps pipeline: `Frontend_Repo` → `frontend-pipeline.yml`

## 🔗 Live URLs

- **Frontend UI**: http://app-capstone-ui-dev-ari999.azurewebsites.net/
- **APIM Gateway**: https://apim-capstone-dev-ari999.azure-api.net
  - Backend A: `/api/A:`
  - Backend B: `/api/B:`

## 📊 CI/CD Pipelines

### Backend Pipeline (Multi-Stage)
4 stages for visual clarity:
1. **Build** - Build Docker images for Backend A & B
2. **Deploy** - Deploy to AKS
3. **Smoke Tests** - Health checks
4. **Post-Deployment** - Summary

### Frontend Pipeline
3 stages:
1. **Build** - Build Docker image with API config
2. **Deploy** - Deploy to Azure Web App
3. **Verify** - Health check

### Terraform Pipeline
Automated infrastructure deployment with drift detection

## 🛠️ Technology Stack

- **Frontend**: React 18.2, Nginx
- **Backend**: Node.js, Express, Multer
- **Database**: PostgreSQL (Azure Database)
- **Container Registry**: Azure Container Registry (ACR)
- **Orchestration**: Azure Kubernetes Service (AKS)
- **API Gateway**: Azure API Management (APIM)
- **IaC**: Terraform
- **CI/CD**: Azure DevOps Pipelines
- **Monitoring**: Prometheus, Grafana, Loki (on AKS)

## 📖 Documentation

- [Backend Pipeline Architecture](docs/BACKEND_PIPELINE_STAGES.md)
- [Backend Pipeline Summary](docs/BACKEND_PIPELINE_SUMMARY.md)
- [Frontend UI Setup](docs/FRONTEND_UI_SETUP_COMPLETE.md)

## 🔧 Development

### Local Frontend Development
```bash
cd capstone-ui
npm install
npm start
```

### APIM Configuration
See [scripts/fix-apim-backend-urls.md](scripts/fix-apim-backend-urls.md)

## 🧪 Testing

### Health Checks
```bash
# Frontend
curl http://app-capstone-ui-dev-ari999.azurewebsites.net/health

# Backend A (via APIM)
curl https://apim-capstone-dev-ari999.azure-api.net/api/A:

# Backend B (via APIM)
curl https://apim-capstone-dev-ari999.azure-api.net/api/B:
```

## 📝 Recent Updates

- ✅ Multi-stage backend pipeline with visual stages
- ✅ Frontend UI fully integrated with APIM
- ✅ CORS configured for cross-origin requests
- ✅ Loading states and error handling in UI
- ✅ Health check endpoints for all services
- ✅ Consolidated project structure (removed duplicates)

## 👥 Contributors

- Ari Sharma
- Claude Sonnet 4.5 (AI Assistant)

## 📄 License

Capstone Project - Educational Use
