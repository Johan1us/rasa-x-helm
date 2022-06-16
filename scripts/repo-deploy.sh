#!/bin/sh
# to activate: $bash script.sh

#echo "What is the name of the project for this deployment?"
#read project
#gcloud config set project $project

echo "What is the name of the cluster for this deployment?"
#read cluster
cluster="production"
echo "$cluster"

gcloud config set container/cluster "$cluster"
echo "Cluster set."
echo ""

# Get the cluster credentials so that kubectl can access the cluster
gcloud container clusters get-credentials --zone europe-west4-a "$cluster"
echo "Credentials received."
echo ""

echo "What is the name of the namespace for this deployment?"
#read namespace
namespace="stuc-concurrent"
echo "$namespace"

kubectl create namespace "$namespace"
echo "Namespace created."
echo ""

echo "What is the name of the GitHub repo for the values.yaml?"
#read values_repo
values_repo="Stuc-Concurrent-Values"
echo "$values_repo"

git clone https://github.com/Johan1us/"$values_repo"
echo "GitHub repo cloned."
echo ""

# change pwd to the GitHub directory
pushd "$values_repo" || exit
echo "Changed pwd to $pwd"
#cd "$values_repo" || exit

# install latest version helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version
echo "Latest helm version installed."
echo ""

# Authenticate with an access token
export HELM_EXPERIMENTAL_OCI=1
gcloud auth print-access-token | helm registry login -u oauth2accesstoken \
--password-stdin https://europe-west4-docker.pkg.dev
echo "Authenticated."
echo ""


helm install \
--namespace "$namespace" \
--values values.yml \
"$namespace" \
oci://europe-west4-docker.pkg.dev/bot-studio-tech/stuc-concurrent-repo/rasa-x

#popd


