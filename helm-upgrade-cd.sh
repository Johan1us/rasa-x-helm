#!/bin/sh
# to activate: $bash script.sh
ls

echo "Install HELM 3"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version

gcloud config set project bot-studio-tech
gcloud config set container/cluster production
gcloud config set compute/zone europe-west4-a
gcloud container clusters get-credentials --zone europe-west4-a production
kubectl create namespace tramhaus

echo "Authenticate with an access token"
export HELM_EXPERIMENTAL_OCI=1
gcloud auth print-access-token | helm registry login -u oauth2accesstoken \
--password-stdin https://europe-west4-docker.pkg.dev


helm upgrade --install --atomic \
--namespace tramhaus \
--values values.yaml \
my-release \
oci://europe-west4-docker.pkg.dev/bot-studio-tech/bot-studio-tech-repo/rasa-x









