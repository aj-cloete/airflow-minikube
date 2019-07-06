#!/bin/bash

IMAGE=${1:-airflow}
TAG=${2:-latest}

# Build docker image within the minikube docker environment for easy access
ENVCONFIG=$(minikube docker-env)
if [ $? -eq 0 ]; then
  eval $ENVCONFIG
fi

# To add dependencies, build like so:
# docker build --build-arg PYTHON_DEPS="Flask-OAuthlib" --build-arg AIRFLOW_DEPS="kubernetes" --tag=${IMAGE}:${TAG} .
docker build --tag=${IMAGE}:${TAG} .

