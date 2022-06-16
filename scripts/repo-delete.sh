#!/bin/sh
# to activate: $bash script.sh

echo "y" | gcloud artifacts repositories delete stuc-concurrent-repo \
--location=europe-west4

