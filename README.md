
# 🚀 Airflow + Databricks on Kubernetes (kind)

A production-style **data platform template** combining orchestration, transformation, and cloud-native infrastructure using Apache Airflow, Databricks, and Kubernetes.


## ✨ Features

* 🔄 End-to-end data pipeline using Apache Airflow 3.0 and Databricks
* 📊 Data-aware orchestration with Airflow Data Assets
* 🧱 Declarative transformations powered by Databricks notebooks
* ⚡ Incremental upsert processing using Delta Lake
* ☸️ Local Kubernetes environment using kind (Kubernetes in Docker)
* 🧪 Data quality validation using DQX
* 🔁 Git-sync sidecar for dynamic DAG synchronization
* 📦 Persistent logging via Kubernetes PV/PVC
* 🔐 Container image management with Amazon Elastic Container Registry
* 🚀 CI/CD pipeline using GitHub Actions
* 📈 Analytics dashboard built with Databricks for insights and monitoring
---

## This project demonstrates a **modern data engineering / MLOps stack**:

* Orchestration → Apache Airflow
* Processing → Databricks
* Storage → S3 + Delta Lake
* Visualization → Databricks Dashboard
* Containers → Docker + Amazon Elastic Container Registry
* Infrastructure → Kubernetes (kind + Helm)
* CI/CD → GitHub Actions

---

## 🏗️ Architecture Overview

```
        +------------------+
        |   Airflow DAGs   |
        +--------+---------+
                 |
                 v
        +------------------+
        |  Airflow (K8s)   |
        |  via Helm Chart  |
        +--------+---------+
                 |
        +--------+---------+
        |                  |
        v                  v
   +---------+       +-------------+
   |   S3    |       | Databricks  |
   | Storage |       |   Jobs      |
   +---------+       +------+------+ 
                              |
                              v
                       +-------------+
                       | Delta Lake  |
                       +------+------+ 
                              |
                              v
                       +-------------+
                       | Dashboard   |
                       +-------------+

                 ^
                 |
        +------------------+
        | Docker Image     |
        | (ECR Registry)   |
        +------------------+
```

---

## 📌 Repository Layout

* `chart/` – Helm values for configuring Airflow
* `cicd/` – Dockerfile for building custom Airflow image
* `dags/` – Airflow DAGs (data ingestion + processing)
* `K8s/` – Kubernetes manifests (PV, PVC, secrets, cluster config)
* `requirements.txt` – Python dependencies
* `airflow-install.sh` – Setup script (cluster + deployment)
* `upgrade_airflow.sh` – Upgrade script (new image + redeploy)

---

## 🧱 How It Works

### 1) Build & Push Image

* Build custom Airflow image (`my-dags:<tag>`)
* Push to Amazon Elastic Container Registry
* Kubernetes pulls the image for deployment

> 💡 Local option: load image directly into kind instead of ECR

---

### 2) Deploy Airflow

* Uses official Helm chart from Apache Airflow
* Applies custom values from `chart/values-override*.yaml`
* Deploys:

  * Scheduler, workers, webserver
  * PV/PVC for logs
  * Git-sync sidecar

---

### 3) Run Data Pipeline

* DAG ingests data → uploads to S3
* Airflow triggers a Databricks job
* Data is transformed and stored using Delta Lake
* Results are visualized in a Databricks dashboard

---

## 🔄 Pipeline Overview

1. Data ingestion via Airflow DAGs
2. Upload to S3
3. Trigger Databricks job
4. Transform data (Delta Lake)
5. Visualize via dashboard

```
[DAGs] → [Airflow] → [S3] → [Databricks] → [Delta] → [Dashboard]
```

---

## 📊 Databricks Dashboard

The project includes a dashboard built in Databricks to visualize processed data and monitor pipeline outputs.

### Key Insights

* Aggregated metrics from processed datasets
* Trend analysis and time-based visualizations
* Data quality monitoring results
* Business-level KPIs derived from transformations

### Workflow

1. Airflow triggers a Databricks job
2. Data is processed and stored in Delta tables
3. Dashboard queries transformed data
4. Insights are visualized in Databricks

### Dashboard Preview

```markdown
![Databricks Dashboard](docs/databricks-dashboard.png)
```

> 📌 Add your screenshot under `docs/databricks-dashboard.png`

---

## ▶️ Getting Started

### 1) Start cluster + install Airflow

```bash
./airflow-install.sh
```

This will:

1. Create kind cluster
2. Build Docker image
3. Load image into cluster / push to ECR
4. Create namespace
5. Apply secrets & volumes
6. Install Airflow via Helm
7. Port-forward UI

---

### 2) Upgrade deployment

```bash
./upgrade_airflow.sh
```

* Build new image
* Upgrade Helm release
* Restart workers automatically

---

## 📄 DAGs Included

* `example_dag.py` — basic example
* `produce_data_assets.py` — ingestion + S3 upload
* `trigger_databricks.py` — triggers Databricks job

---

## 🔐 Secrets & Credentials

### Git-sync configuration

```yaml
dags:
  gitSync:
    enabled: true
    repo: <your-repo>
    branch: <branch>
    credentialsSecret: git-credentials
```

---

## 🔄 CI/CD

* Docker image build & push to Amazon Elastic Container Registry
* Versioned tagging (timestamp-based)
* Deployment via Helm upgrade
* Automated via GitHub Actions

---

## 🧪 Troubleshooting

### Check pods

```bash
kubectl get pods -n airflow
```

### View logs

```bash
kubectl logs -n airflow -l component=webserver
```

### Reset cluster

```bash
kind delete cluster --name kind
```

---

## 📦 Customization

* Add dependencies → `requirements.txt`
* Add DAGs → `dags/`
* Modify configs → `chart/values-override*.yaml`
* Switch executor (Celery, Local, etc.)

---

## 🧠 Notes

* Designed for **local development & testing**
* Mimics a **production-grade data platform**
* Easily extendable to cloud environments (EKS, GKE, etc.)



