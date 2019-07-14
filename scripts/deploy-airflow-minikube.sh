#!/bin/bash

BASEDIR=$(dirname "$0")

# Start the minikube cluster
/bin/bash $BASEDIR/start_minikube.sh;

# Apply the tiller service account on the minikube cluster
kubectl apply -f $BASEDIR/../airflow/tiller.yaml
helm init --service-account tiller --upgrade
helm dependency update $BASEDIR/../airflow
helm upgrade --install airflow $BASEDIR/../airflow/. --namespace=airflow
kubectl config set-context --current --namespace=airflow
