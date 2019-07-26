#! /bin/bash
# This script deletes the helm airflow deployment completely
helm delete --purge airflow
echo $(helm list -a)
