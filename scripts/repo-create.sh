#!/bin/sh
# to activate: $bash script.sh

echo "What is the name of the repo for this deployment?"
#read repo
repo="stuc-concurrent"
echo "$repo"

gcloud artifacts repositories create "$repo"-repo \
--repository-format=docker \
--location=europe-west4

git clone https://github.com/Johan1us/rasa-x-helm

pushd rasa-x-helm/charts/rasa-x || exit

helm dependency update

pushd ..

helm package rasa-x

export HELM_EXPERIMENTAL_OCI=1
gcloud auth print-access-token | helm registry login -u oauth2accesstoken \
--password-stdin https://europe-west4-docker.pkg.dev

helm push rasa-x-0.0.1.tgz oci://europe-west4-docker.pkg.dev/bot-studio-tech/stuc-concurrent-repo
