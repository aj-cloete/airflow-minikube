#!/bin/bash
# This script updates the airflow kubernetes deployment

set -x

echo Updating Airflow deployment

_MY_SCRIPT="${BASH_SOURCE[0]}"
BASEDIR=$(cd "$(dirname "$_MY_SCRIPT")" && pwd)

helm dependency update $BASEDIR/../airflow
if [[ ! $(docker images | grep airflow) ]]; then
  /bin/bash $BASEDIR/../docker/build-docker.sh
fi
helm upgrade --install airflow $BASEDIR/../airflow/. --namespace=airflow
kubectl config set-context --current --namespace=airflow

echo Airflow deployment updated!
