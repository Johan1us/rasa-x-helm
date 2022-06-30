#!/bin/sh
# to activate: $bash script.sh

echo "Install HELM 3"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version

echo "Authenticate with an access token"
export HELM_EXPERIMENTAL_OCI=1
gcloud auth print-access-token | helm registry login -u oauth2accesstoken \
--password-stdin https://europe-west4-docker.pkg.dev

echo "Clone git repo"
git clone https://github.com/Johan1us/rasa-x-helm

pushd rasa-x-helm/charts/rasa-x || exit

echo "Update HELM dependencies"
helm dependency update

pushd ..

echo "Package HELM Chart"
helm package rasa-x

echo "Push HELM Chart"
helm push rasa-x-0.0.3tgz oci://europe-west4-docker.pkg.dev/bot-studio-tech/bot-studio-tech-repo
