#!/bin/bash

# ----------------------------------------
# Airflow Upgrade Script (kind + Helm)
# ----------------------------------------

set -e

# Config
export IMAGE_NAME=my-dags
export IMAGE_TAG=$(date +%Y%m%d%H%M%S)
export NAMESPACE=airflow
export RELEASE_NAME=airflow

echo "🔹 Building Airflow Docker image: $IMAGE_NAME:$IMAGE_TAG"
docker build --pull --tag $IMAGE_NAME:$IMAGE_TAG -f cicd/Dockerfile .

echo "🔹 Loading image into kind cluster"
kind load docker-image $IMAGE_NAME:$IMAGE_TAG

echo "🔹 Upgrading Airflow via Helm"
helm upgrade --install $RELEASE_NAME apache-airflow/airflow \
  --namespace $NAMESPACE \
  -f chart/values-override.yaml \
  --set-string images.airflow.repository=$IMAGE_NAME \
  --set-string images.airflow.tag=$IMAGE_TAG \
  --debug \
  --timeout 17m
kubectl apply -f K8s/secrets/git-credentials.yaml
kubectl apply -f k8s/volumes/airflow-logs-pv.yaml
kubectl apply -f k8s/volumes/airflow-logs-pvc.yaml
# ----------------------------------------
# Force StatefulSets to use new image
# ----------------------------------------
echo "🔹 Patching StatefulSets to trigger rolling update"
for sts in airflow-worker airflow-triggerer; do
  kubectl patch statefulset $sts -n $NAMESPACE \
    -p "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"date\":\"$(date +%s)\"}}}}}"
done

# ----------------------------------------
# Restart deployments
# ----------------------------------------
echo "🔹 Restarting deployments"
for deploy in airflow-api-server airflow-scheduler airflow-dag-processor airflow-statsd; do
  kubectl rollout restart deployment $deploy -n $NAMESPACE
done

# ----------------------------------------
# Wait for all pods to be ready
# ----------------------------------------
echo "🔹 Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pods --all -n $NAMESPACE --timeout=600s

echo "✅ All pods are ready. Current pods:"
kubectl get pods -n $NAMESPACE

# ----------------------------------------
# Port-forward API server
# ----------------------------------------
echo "🔹 Starting port-forward to API server"
# kubectl port-forward svc/$RELEASE_NAME-api-server 8080:8080 --namespace $NAMESPACE
kubectl port-forward svc/airflow-api-server 8080:8080 --namespace airflow