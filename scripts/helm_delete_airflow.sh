#! /bin/bash
# This script deletes the helm airflow deployment completely

# Ensure we're using the minikube docker local repo
eval $(minikube docker-env)
helm delete --purge airflow
echo $(helm list -a)
