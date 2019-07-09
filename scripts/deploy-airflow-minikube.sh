#!/bin/bash

BASEDIR=$(dirname "$0")

# Start the minikube cluster
/bin/bash $BASEDIR/minikube-start.sh;

# Apply the tiller service account on the minikube cluster
kubectl apply -f $BASEDIR/../airflow/tiller.yaml
helm init --service-account tiller --upgrade
helm dependency update $BASEDIR/../airflow
helm install --namespace "airflow" --name "airflow" $BASEDIR/../airflow/.
