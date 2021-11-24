#!/bin/bash

IMAGE_NAME=patient-browser
TMP_FOLDER=tmp_build_patient_browser

## Get version tag and registry-prefix from .env:
source ../.env

printf "\n\n##################################\n"
printf "Building $REGISTRY_PREFIX/$IMAGE_NAME:$PATIENT_BROWSER_TAG"
printf "\n##################################\n"

printf "\n\nPlease insert your login credentials to registry: $REGISTRY_PREFIX ...\n"
docker login

printf "\n\nCloning patient-browser data\n"
rm -rf $TMP_FOLDER
git clone https://github.com/Alvearie/patient-browser.git $TMP_FOLDER

printf "\nPulling cached $IMAGE_NAME image\n"
# pull latest image for caching:
docker pull $REGISTRY_PREFIX/$IMAGE_NAME
# build new image (latest):
docker build \
    --progress=plain \
    --no-cache=true \
    --label "org.label-schema.name=joundso/$IMAGE_NAME" \
    --label "org.label-schema.vsc-url=https://github.com/joundso/docker-collection/blob/master/custom_dockerfiles/patient-browser.dockerfile" \
    --label "org.label-schema.vcs-ref=$(git rev-parse HEAD)" \
    --label "org.label-schema.version=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    -f ./$IMAGE_NAME.dockerfile \
    -t $REGISTRY_PREFIX/$IMAGE_NAME . 2>&1 | tee ./log_$IMAGE_NAME.log
printf "\n\nPushing $IMAGE_NAME image (latest)\n"
# push new image as new 'latest':
docker push "$REGISTRY_PREFIX/$IMAGE_NAME"
# also tag it with the new tag:
docker tag $REGISTRY_PREFIX/$IMAGE_NAME $REGISTRY_PREFIX/$IMAGE_NAME:$PATIENT_BROWSER_TAG
# and also push this (tagged) image:
printf "\n\nPushing $IMAGE_NAME image ($PATIENT_BROWSER_TAG)\n"
docker push "$REGISTRY_PREFIX/$IMAGE_NAME:$PATIENT_BROWSER_TAG"

rm -rf $TMP_FOLDER
