#!/bin/bash
# This script builds the airflow docker image from this folder
set -x
_MY_SCRIPT="${BASH_SOURCE[0]}"
BASEDIR=$(cd "$(dirname "$_MY_SCRIPT")" && pwd)

cd $BASEDIR

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

# For vanilla build, uncomment line below and delete anything further down
# docker build --tag=${IMAGE}:${TAG} .

# To pre-bake git repos into your image (to save on startup time) use the template below
# The two args ending in GIT_CLONE_COMMAND should be quoted with double quotes and will look something like this
# DAGS_GIT_CLONE_COMMAND="git clone {repo} --flags "
# The correspondingly-named _DESTINATION variables will be added to the end of the git command to tell git where to clone to
# Do not leave the _DESTINATION variables empty if you want the entrypoint script to pull from the repo(s) at container startup
   
docker build \
--tag=${IMAGE}:${TAG} \
--build-arg DAGS_GIT_CLONE_COMMAND="$DAGS_GIT_CLONE_COMMAND" \
--build-arg DAGS_DESTINATION="$DAGS_DESTINATION" \
--build-arg SQL_GIT_CLONE_COMMAND="$SQL_GIT_CLONE_COMMAND" \
--build-arg SQL_DESTINATION="$SQL_DESTINATION" \
.  
