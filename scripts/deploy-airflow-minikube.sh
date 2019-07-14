#!/bin/bash

BASEDIR=$(dirname "$0")

# Start the minikube cluster
/bin/bash $BASEDIR/start_minikube.sh;

if [[ ! $(which helm) ]]; then
  echo Installing helm which is required for deploying to kubernetes
  curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
  chmod +x get_helm.sh
  sudo sh get_helm.sh
  sudo rm get_helm.sh
fi

# Apply the tiller service account on the minikube cluster
kubectl apply -f $BASEDIR/../airflow/tiller.yaml
helm init --service-account tiller --upgrade
helm dependency update $BASEDIR/../airflow
helm upgrade --install airflow $BASEDIR/../airflow/. --namespace=airflow
kubectl config set-context --current --namespace=airflow
