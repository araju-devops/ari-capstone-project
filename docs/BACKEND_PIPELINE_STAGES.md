# Backend Pipeline - Multi-Stage Visual Architecture

## Pipeline Overview

The backend pipeline is organized into **4 distinct stages** for better visibility, maintainability, and control.

```
┌─────────────────────────────────────────────────────────────────┐
│                     BACKEND CI/CD PIPELINE                      │
└─────────────────────────────────────────────────────────────────┘

   ┌──────────────┐      ┌──────────────┐      ┌──────────────┐      ┌──────────────┐
   │   STAGE 1    │      │   STAGE 2    │      │   STAGE 3    │      │   STAGE 4    │
   │              │      │              │      │              │      │              │
   │    BUILD     │─────▶│  DEPLOY DEV  │─────▶│ SMOKE TESTS  │─────▶│POST-DEPLOY   │
   │              │      │              │      │              │      │              │
   └──────────────┘      └──────────────┘      └──────────────┘      └──────────────┘
```

---

## Stage 1: Build & Push Images 🏗️

**Purpose**: Build Docker images for both backends and push to Azure Container Registry

### Jobs:
1. **Build Backend A**
   - Build Docker image from `./backend-a`
   - Tag with `latest` and build ID
   - Push to ACR: `acrcapstoneari999.azurecr.io/backend-a`

2. **Build Backend B**
   - Build Docker image from `./backend-b`
   - Tag with `latest` and build ID
   - Push to ACR: `acrcapstoneari999.azurecr.io/backend-b`

### Visual Flow:
```
Build Backend A (Job 1)           Build Backend B (Job 2)
       │                                  │
       ├─ docker build                    ├─ docker build
       ├─ docker tag :latest              ├─ docker tag :latest
       ├─ docker tag :buildId             ├─ docker tag :buildId
       ├─ docker push :latest             ├─ docker push :latest
       └─ docker push :buildId            └─ docker push :buildId
```

### Artifacts:
- `backend-a:latest` and `backend-a:<buildId>`
- `backend-b:latest` and `backend-b:<buildId>`

---

## Stage 2: Deploy to DEV 🚀

**Purpose**: Deploy both backends to AKS Development environment

### Deployment Strategy:
- **Type**: `runOnce` deployment
- **Environment**: `aks-dev`
- **Namespace**: `microservices-app`

### Steps:
```
1. Get AKS Credentials
   └─ Connect to aks-capstone-dev cluster

2. Create Namespace
   └─ Apply 01-namespace.yaml

3. Apply Secrets
   └─ Apply 02-secrets.yaml (DB credentials)

4. Apply ConfigMap
   └─ Apply 03-configmap.yaml (Environment config)

5. Apply Services
   └─ Apply 04-services.yaml (LoadBalancer services)

6. Deploy Backend A
   └─ Apply 05-backend-a-deployment.yaml

7. Deploy Backend B
   └─ Apply 06-backend-b-deployment.yaml

8. Verify Deployment
   └─ Check rollout status
   └─ Display pods, deployments, and services
```

### Visual Flow:
```
┌─────────────────┐
│ Get AKS Creds   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Create Namespace│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Apply Secrets   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Apply ConfigMap │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Apply Services  │
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌─────────┐ ┌─────────┐
│Backend A│ │Backend B│
│ Deploy  │ │ Deploy  │
└────┬────┘ └────┬────┘
     │           │
     └─────┬─────┘
           ▼
    ┌──────────────┐
    │Verify Status │
    └──────────────┘
```

---

## Stage 3: Smoke Tests 🧪

**Purpose**: Verify that deployed services are healthy and accessible

### Health Checks:
1. **Get Service IPs**
   - Retrieve external LoadBalancer IPs for both backends

2. **Test Backend A**
   - `curl http://<BACKEND_A_IP>:8080/health`
   - Verify HTTP 200 response

3. **Test Backend B**
   - `curl http://<BACKEND_B_IP>:8080/health`
   - Verify HTTP 200 response

### Visual Flow:
```
┌──────────────────┐
│ Get Service IPs  │
└────────┬─────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌─────────┐ ┌─────────┐
│Backend A│ │Backend B│
│ Health  │ │ Health  │
│  Check  │ │  Check  │
└────┬────┘ └────┬────┘
     │           │
     └─────┬─────┘
           ▼
    ┌──────────────┐
    │All Tests Pass│
    └──────────────┘
```

### Success Criteria:
- ✅ Backend A responds with HTTP 200
- ✅ Backend B responds with HTTP 200
- ✅ Both services return valid health status

---

## Stage 4: Post-Deployment 📊

**Purpose**: Display deployment summary and send notifications

### Summary Information:
- Build ID and Build Number
- Target cluster and namespace
- Container image tags
- Access URLs via APIM

### Visual Output:
```
========================================
🎉 DEPLOYMENT COMPLETE
========================================

Build ID: 237
Build Number: 20260110.4
Deployed to: aks-capstone-dev
Namespace: microservices-app

Container Images:
  - acrcapstoneari999.azurecr.io/backend-a:237
  - acrcapstoneari999.azurecr.io/backend-b:237

Access your backends via APIM:
  - Backend A: https://apim-capstone-dev-ari999.azure-api.net/api/A:
  - Backend B: https://apim-capstone-dev-ari999.azure-api.net/api/B:

========================================
```

---

## Stage Dependencies

```
Build
  │
  └─── (on success) ───┐
                       ▼
                   DeployDev
                       │
                       └─── (on success) ───┐
                                            ▼
                                        SmokeTests
                                            │
                                            └─── (on success) ───┐
                                                                 ▼
                                                            PostDeployment
```

### Dependency Rules:
1. **DeployDev** only runs if **Build** succeeds
2. **SmokeTests** only runs if **DeployDev** succeeds
3. **PostDeployment** only runs if **SmokeTests** succeeds

---

## Benefits of Multi-Stage Pipeline

### 1. **Visual Clarity** 👁️
- Easy to see pipeline progress in Azure DevOps
- Each stage has a clear, distinct purpose
- Quick identification of failures

### 2. **Better Control** 🎛️
- Can manually approve stages (add approvals if needed)
- Can retry individual stages without re-running entire pipeline
- Easier to debug specific stage failures

### 3. **Parallel Execution** ⚡
- Backend A and Backend B build in parallel (separate jobs)
- Faster overall pipeline execution

### 4. **Maintainability** 🔧
- Each stage is self-contained
- Easy to add new stages (e.g., QA, Prod)
- Clear separation of concerns

### 5. **Auditing** 📋
- Clear audit trail of what ran when
- Easy to see which stage failed
- Better logging and troubleshooting

---

## Future Enhancements

### Add QA Stage:
```yaml
- stage: DeployQA
  displayName: 'Deploy to QA'
  dependsOn: SmokeTests
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
```

### Add Production Stage with Manual Approval:
```yaml
- stage: DeployProd
  displayName: 'Deploy to Production'
  dependsOn: DeployQA
  condition: succeeded()
  jobs:
  - deployment: DeployToProd
    environment: 'aks-production'  # Requires manual approval in Azure DevOps
```

### Add Integration Tests:
```yaml
- stage: IntegrationTests
  displayName: 'Integration Tests'
  dependsOn: SmokeTests
  jobs:
  - job: RunTests
    steps:
    - script: npm test
```

---

## Monitoring Pipeline Execution

### In Azure DevOps:
1. Navigate to **Pipelines** → **Backend_Repo**
2. View the visual stage diagram
3. Click on any stage to see detailed logs
4. Monitor real-time progress

### Visual Indicators:
- 🔵 **Blue**: Stage is running
- ✅ **Green**: Stage succeeded
- ❌ **Red**: Stage failed
- ⏸️ **Gray**: Stage skipped/not started

---

## Conclusion

This multi-stage architecture provides:
- **Clarity**: Easy to understand what's happening
- **Control**: Fine-grained control over deployment
- **Speed**: Parallel execution where possible
- **Safety**: Health checks before completion
- **Visibility**: Clear progress tracking

Each stage builds upon the previous one, ensuring a reliable and repeatable deployment process! 🚀
