#!/bin/bash

IMAGE=${1:-airflow}
TAG=${2:-latest}

# Build docker image within the minikube docker environment for easy access
ENVCONFIG=$(minikube docker-env)
if [ $? -eq 0 ]; then
  eval $ENVCONFIG
fi

# To add dependencies, build like so:
# docker build --build-arg PYTHON_DEPS="Flask-OAuthlib psycopg2-binary" --build-arg AIRFLOW_DEPS="kubernetes,snowflake" --tag=${IMAGE}:${TAG} .
# For extra pip settings, add requirements.txt file to the docker folder
docker build --tag=${IMAGE}:${TAG} .
