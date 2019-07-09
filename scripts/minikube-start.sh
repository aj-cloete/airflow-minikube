#!/bin/bash

export CHANGE_MINIKUBE_NONE_USER=true

if minikube status | grep kubectl | grep Correctly ; then 
  echo "Minikube already running"; else
  minikube start --kubernetes-version=${_KUBERNETES_VERSION} --vm-driver=${_VM_DRIVER};
  minikube update-context
fi
