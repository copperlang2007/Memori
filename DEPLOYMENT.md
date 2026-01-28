# Memori Deployment Guide

This guide covers deploying Memori's documentation site and demo applications.

## Table of Contents

- [Quick Start with Docker](#quick-start-with-docker)
- [Documentation Deployment](#documentation-deployment)
- [Demo Apps Deployment](#demo-apps-deployment)
- [Production Deployment](#production-deployment)
- [Environment Variables](#environment-variables)

## Quick Start with Docker

### Prerequisites

- Docker (version 20.10+)
- Docker Compose (version 2.0+)
- Git

### Running Everything Locally

1. Clone the repository:
```bash
git clone https://github.com/GibsonAI/memori.git
cd memori
```

2. Create a `.env` file with your API keys:
```bash
cp .env.example .env
# Edit .env and add your API keys
```

3. Start all services:
```bash
docker-compose up -d
```

This will start:
- **Documentation**: http://localhost:8000
- **Personal Diary Demo**: http://localhost:8501
- **Researcher Agent Demo**: http://localhost:8502
- **Travel Planner Demo**: http://localhost:8503
- **Job Search Agent Demo**: http://localhost:8504
- **Product Launch Demo**: http://localhost:8505

### Running Individual Services

```bash
# Documentation only
docker-compose up docs

# Specific demo
docker-compose up diary-demo
docker-compose up researcher-demo
```

### Building from Dockerfile

Build specific stages:

```bash
# Production SDK
docker build --target production -t memori:latest .

# Documentation
docker build --target docs -t memori-docs:latest .

# Demo apps
docker build --target demos -t memori-demos:latest .
```

## Documentation Deployment

### GitHub Pages (Automated)

The documentation is automatically deployed to GitHub Pages when changes are pushed to the `main` branch.

**Setup:**

1. Enable GitHub Pages in repository settings
2. Set source to "GitHub Actions"
3. Push changes to `docs/` or `mkdocs.yml`

The deployment workflow (`.github/workflows/deploy-docs.yml`) will:
- Build the documentation with MkDocs
- Deploy to GitHub Pages
- Make it available at: `https://[username].github.io/Memori/`

### Manual Documentation Build

```bash
# Install dependencies
pip install mkdocs mkdocs-material

# Build documentation
mkdocs build

# Serve locally for testing
mkdocs serve
```

### Custom Domain

To use a custom domain:

1. Add a `CNAME` file to `docs/` directory:
```bash
echo "docs.yourdomain.com" > docs/CNAME
```

2. Configure DNS settings at your domain provider:
```
Type: CNAME
Name: docs
Value: [username].github.io
```

## Demo Apps Deployment

### Streamlit Cloud

Each demo can be deployed to Streamlit Cloud:

1. **Fork the repository** to your GitHub account

2. **Go to Streamlit Cloud** (https://streamlit.io/cloud)

3. **Deploy a new app**:
   - Repository: `[your-username]/memori`
   - Branch: `main`
   - Main file path: `demos/[app-name]/[main-file].py`

4. **Add secrets** in Streamlit Cloud dashboard:
```toml
OPENAI_API_KEY = "sk-..."
TAVILY_API_KEY = "tvly-..."
```

#### Demo App Entry Points

- **Personal Diary**: `demos/personal_diary_assistant/streamlit_app.py`
- **Researcher Agent**: `demos/researcher_agent/app.py`
- **Travel Planner**: `demos/travel_planner/app.py`
- **Job Search Agent**: `demos/job_search_agent/app.py`
- **Product Launch**: `demos/product_launch_agent/chat_app.py`

### Railway

Deploy to Railway for production-ready hosting:

1. **Install Railway CLI**:
```bash
npm install -g @railway/cli
```

2. **Login and initialize**:
```bash
railway login
railway init
```

3. **Deploy a demo**:
```bash
cd demos/personal_diary_assistant
railway up
```

4. **Set environment variables**:
```bash
railway variables set OPENAI_API_KEY=sk-...
railway variables set MEMORI_DATABASE__CONNECTION_STRING=postgresql://...
```

### Render

Deploy to Render:

1. Create a `render.yaml` in the demo directory:
```yaml
services:
  - type: web
    name: memori-diary-demo
    env: python
    buildCommand: "pip install -r requirements.txt"
    startCommand: "streamlit run streamlit_app.py --server.port=$PORT"
    envVars:
      - key: OPENAI_API_KEY
        sync: false
      - key: PYTHON_VERSION
        value: 3.11.0
```

2. Connect your GitHub repo in Render dashboard
3. Select the service and deploy

### Heroku

Deploy to Heroku:

1. Create required files in demo directory:

**Procfile**:
```
web: streamlit run streamlit_app.py --server.port=$PORT --server.address=0.0.0.0
```

**runtime.txt**:
```
python-3.11.0
```

2. Deploy:
```bash
cd demos/personal_diary_assistant
heroku create memori-diary-demo
git push heroku main
heroku config:set OPENAI_API_KEY=sk-...
```

## Production Deployment

### Using Docker in Production

#### Docker Swarm

1. **Initialize Swarm**:
```bash
docker swarm init
```

2. **Deploy stack**:
```bash
docker stack deploy -c docker-compose.yml memori
```

3. **Scale services**:
```bash
docker service scale memori_diary-demo=3
```

#### Kubernetes

Create Kubernetes manifests:

**deployment.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: memori-docs
spec:
  replicas: 2
  selector:
    matchLabels:
      app: memori-docs
  template:
    metadata:
      labels:
        app: memori-docs
    spec:
      containers:
      - name: docs
        image: memori-docs:latest
        ports:
        - containerPort: 8000
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

**service.yaml**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: memori-docs
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8000
  selector:
    app: memori-docs
```

Deploy:
```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### Cloud Platform Deployments

#### AWS (ECS)

1. Build and push to ECR:
```bash
aws ecr create-repository --repository-name memori-demos
docker build --target demos -t memori-demos:latest .
docker tag memori-demos:latest [account-id].dkr.ecr.[region].amazonaws.com/memori-demos:latest
docker push [account-id].dkr.ecr.[region].amazonaws.com/memori-demos:latest
```

2. Create ECS task definition and service through AWS console or CLI

#### Google Cloud (Cloud Run)

```bash
# Build and deploy
gcloud builds submit --tag gcr.io/[project-id]/memori-docs
gcloud run deploy memori-docs \
  --image gcr.io/[project-id]/memori-docs \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

#### Azure (Container Apps)

```bash
# Create container registry
az acr create --resource-group memori-rg --name memoriacr --sku Basic

# Build and push
az acr build --registry memoriacr --image memori-docs:latest .

# Deploy to Container Apps
az containerapp create \
  --name memori-docs \
  --resource-group memori-rg \
  --image memoriacr.azurecr.io/memori-docs:latest \
  --target-port 8000 \
  --ingress external
```

## Environment Variables

### Required Variables

```bash
# OpenAI API Key (required for all demos)
OPENAI_API_KEY=sk-...

# Database connection (optional, defaults to SQLite)
MEMORI_DATABASE__CONNECTION_STRING=postgresql://user:pass@host/db

# Memori Configuration
MEMORI_MEMORY__NAMESPACE=production
MEMORI_AGENTS__OPENAI_API_KEY=sk-...
```

### Demo-Specific Variables

**Researcher Agent**:
```bash
TAVILY_API_KEY=tvly-...
EXA_API_KEY=...
```

**Product Launch Agent**:
```bash
OPENAI_API_KEY=sk-...
```

### Setting Environment Variables

**Docker Compose**:
Create `.env` file in the project root.

**Kubernetes**:
```bash
kubectl create secret generic memori-secrets \
  --from-literal=openai-api-key=sk-...
```

**Streamlit Cloud**:
Add in the app settings under "Secrets" section.

**Cloud Platforms**:
- AWS: Use AWS Secrets Manager or Parameter Store
- GCP: Use Secret Manager
- Azure: Use Key Vault

## Health Checks and Monitoring

### Docker Health Checks

The Dockerfile includes health checks:
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import memori; print(memori.__version__)" || exit 1
```

### Application Monitoring

Add monitoring with Prometheus:

```yaml
# docker-compose.monitoring.yml
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
  
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
```

## SSL/TLS Configuration

### Using Caddy (Recommended)

Create `Caddyfile`:
```
docs.yourdomain.com {
    reverse_proxy docs:8000
}

diary.yourdomain.com {
    reverse_proxy diary-demo:8501
}
```

Add to docker-compose.yml:
```yaml
services:
  caddy:
    image: caddy:2
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
```

### Using Nginx + Let's Encrypt

See detailed configuration in `docs/deployment/nginx-ssl.md`

## Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs [service-name]

# Rebuild without cache
docker-compose build --no-cache [service-name]
```

### Port conflicts
```bash
# Check what's using the port
lsof -i :8501

# Change port in docker-compose.yml
ports:
  - "8502:8501"  # Use different external port
```

### Memory issues
```bash
# Increase Docker memory limit
# Docker Desktop: Settings -> Resources -> Memory

# Or limit service memory in docker-compose.yml
services:
  docs:
    deploy:
      resources:
        limits:
          memory: 1G
```

## Support

For deployment issues:
- **Documentation**: https://memorilabs.ai/docs
- **GitHub Issues**: https://github.com/GibsonAI/memori/issues
- **Discord**: https://discord.gg/abD4eGym6v

## License

Apache 2.0 - see [LICENSE](../LICENSE) for details
