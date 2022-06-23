gcloud services enable container.googleapis.com \
    cloudbuild.googleapis.com \
    sourcerepo.googleapis.com \
    artifactregistry.googleapis.com

gcloud artifacts repositories create my-repository \
  --repository-format=docker \
  --location=us-central1

gcloud container clusters create hello-cloudbuild \
    --num-nodes 1 --region us-central1


gcloud source repos create hello-cloudbuild-app
gcloud source repos create hello-cloudbuild-env

cd ~
git clone https://github.com/GoogleCloudPlatform/gke-gitops-tutorial-cloudbuild \
    hello-cloudbuild-app

#cd ~/hello-cloudbuild-app
#COMMIT_ID="$(git rev-parse --short=7 HEAD)"
#gcloud builds submit --tag="europe-west4-docker.pkg.dev/${PROJECT_ID}/stuc-concurrent-repo/hello-cloudbuild:${COMMIT_ID}" .

cd ~/hello-cloudbuild-app
PROJECT_ID=$(gcloud config get-value project)
git remote add google \
    "https://source.developers.google.com/p/${PROJECT_ID}/r/hello-cloudbuild-app"

cd ~/hello-cloudbuild-app
COMMIT_ID="$(git rev-parse --short=7 HEAD)"
gcloud builds submit --tag="us-central1-docker.pkg.dev/${PROJECT_ID}/my-repository/hello-cloudbuild:${COMMIT_ID}" .

cd ~/hello-cloudbuild-app
git push google master


PROJECT_NUMBER="$(gcloud projects describe ${PROJECT_ID} --format='get(projectNumber)')"
gcloud projects add-iam-policy-binding ${PROJECT_NUMBER} \
    --member=serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com \
    --role=roles/container.developer

cd ~
gcloud source repos clone hello-cloudbuild-env
cd ~/hello-cloudbuild-env
git checkout -b production

cd ~/hello-cloudbuild-env
cp ~/hello-cloudbuild-app/cloudbuild-delivery.yaml ~/hello-cloudbuild-env/cloudbuild.yaml
git add .
git commit -m "Create cloudbuild.yaml for deployment"

git checkout -b candidate
git push origin production
git push origin candidate

PROJECT_NUMBER="$(gcloud projects describe ${PROJECT_ID} \
    --format='get(projectNumber)')"
cat >/tmp/hello-cloudbuild-env-policy.yaml <<EOF
bindings:
- members:
  - serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com
  role: roles/source.writer
EOF
gcloud source repos set-iam-policy \
    hello-cloudbuild-env /tmp/hello-cloudbuild-env-policy.yaml

cd ~/hello-cloudbuild-app
cp cloudbuild-trigger-cd.yaml cloudbuild.yaml

cd ~/hello-cloudbuild-app
git add cloudbuild.yaml
git commit -m "Trigger CD pipeline"
git push google master

cd ~/hello-cloudbuild-app
sed -i 's/Hello World/Hello Cloud Build/g' app.py
sed -i 's/Hello World/Hello Cloud Build/g' test_app.py

git add app.py test_app.py
git commit -m "Hello Cloud Build"
git push google master


git rev-list --count master

