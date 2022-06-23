PROJECT_ID=$(gcloud config get-value project)

PROJECT_NUMBER="$(gcloud projects describe ${PROJECT_ID} --format='get(projectNumber)')"
gcloud projects add-iam-policy-binding ${PROJECT_NUMBER} \
    --member=serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com \
    --role=roles/container.developer

gcloud source repos create hello-cloudbuild-env

cd ~
gcloud source repos clone github_johan1us_stuc-concurrent-app-env
cd ~/github_johan1us_stuc-concurrent-app-env
git checkout -b production