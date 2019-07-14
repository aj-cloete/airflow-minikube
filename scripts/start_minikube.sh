# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# This script was based on one made by @kimoonkim for kubernetes-hdfs

#!/usr/bin/env bash

set -ex

if [[ -x /usr/local/bin/minikube ]]; then
  echo Minikube already installed
  if [[ $(minikube status | grep "Correctly Configured") ]]; then
    echo Minikube already up and running!
    exit 0
  fi
fi

_MY_SCRIPT="${BASH_SOURCE[0]}"
_MY_DIR=$(cd "$(dirname "$_MY_SCRIPT")" && pwd)
_KUBERNETES_VERSION="${KUBERNETES_VERSION:-$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)}"
_MINIKUBE_VERSION="${MINIKUBE_VERSION:-latest}"

echo "setting up kubernetes ${_KUBERNETES_VERSION}, using minikube ${_MINIKUBE_VERSION}"

_VM_DRIVER="${VM_DRIVER:-none}"

_UNAME_OUT=$(uname -s)
case "${_UNAME_OUT}" in
    Linux*)
      _MY_OS=linux
      _VM_DRIVER=none
      if [[ ! -x /usr/bin/socat ]]; then
        sudo apt-get install -y socat
      fi
    ;;
    Darwin*)
      _MY_OS=darwin
      unset _VM_DRIVER
    ;;
    *)
      echo "${_UNAME_OUT} is unsupported."
      exit 1
    ;;
esac
echo "Local OS is ${_MY_OS}"

export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export CHANGE_MINIKUBE_NONE_USER=true

cd $_MY_DIR

source _k8s.sh

mkdir -p bin

if [[ ! -d /usr/local/bin ]]; then
    sudo mkdir -p /usr/local/bin
fi

if [[ ! -x /usr/local/bin/kubectl ]]; then
  echo Downloading kubectl, which is a requirement for using minikube.
  curl -Lo bin/kubectl  \
    https://storage.googleapis.com/kubernetes-release/release/${_KUBERNETES_VERSION}/bin/${_MY_OS}/amd64/kubectl
  chmod +x bin/kubectl
  sudo mv bin/kubectl /usr/local/bin/kubectl
fi
if [[ ! -x /usr/local/bin/minikube ]]; then
  echo Downloading minikube.
  curl -Lo bin/minikube  \
    https://storage.googleapis.com/minikube/releases/latest/minikube-${_MY_OS}-amd64
  chmod +x bin/minikube
  sudo mv bin/minikube /usr/local/bin/minikube
fi

if [[ ! $(which docker) ]]; then
  echo Downloading docker which is a requirement for using minikube.
  cd $_MY_DIR/bin
  curl -fsSl https://get.docker.com -Lo get-docker.sh
  sudo sh get-docker.sh
  sudo usermod -aG docker $USER || :
  cd $_MY_DIR
fi

rm -rf bin

export PATH="${_MY_DIR}/bin:$PATH"
echo "your path is ${PATH}"

case "${_MY_OS}" in
  linux*)
    _MINIKUBE="sudo -E PATH=$PATH minikube"
    _MEM=free -m | grep Mem | awk '{print $2}'
    ;;
  *)
    _MINIKUBE="PATH=$PATH minikube";;
    _MEM=4096
esac

if [[ ! $($_MINIKUBE status | grep "Correctly Configured") ]]; then
  $_MINIKUBE start --memory ${_MEM} --kubernetes-version=${_KUBERNETES_VERSION} --vm-driver=${_VM_DRIVER}
  $_MINIKUBE update-context; else
  $_MINIKUBE status;
fi

# Wait for Kubernetes to be up and ready.
k8s_single_node_ready

echo Minikube addons:
$_MINIKUBE addons list
kubectl get storageclass
echo Showing kube-system pods
kubectl get -n kube-system pods

(k8s_single_pod_ready -n kube-system -l component=kube-addon-manager) ||
  (_ADDON=$(kubectl get pod -n kube-system -l component=kube-addon-manager \
      --no-headers -o name| cut -d/ -f2);
   echo Addon-manager describe:;
   kubectl describe pod -n kube-system $_ADDON;
   echo Addon-manager log:;
   kubectl logs -n kube-system $_ADDON;
   exit 1)
k8s_single_pod_ready -n kube-system -l k8s-app=kube-dns
k8s_single_pod_ready -n kube-system storage-provisioner
