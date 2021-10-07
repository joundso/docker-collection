#!/bin/bash

## Get version tag and registry-prefix from .env:
source ./.env

DIRECTORY=./dockerfiles

for i in $DIRECTORY/*.dockerfile; do
    ## Remove path:
    IMAGE_NAME=${i##*/}
    ## ... and file ending:
    IMAGE_NAME="${IMAGE_NAME%.*}"

    printf "\n\n##################################\n"
    printf "Building $REGISTRY_PREFIX/$IMAGE_NAME:$ALPINE_VERSION_TAG"
    printf "\n##################################\n"

    printf "\n\nPlease insert your login credentials to registry: $REGISTRY_PREFIX ...\n"
    docker login

    printf "\nPulling cached $IMAGE_NAME image\n"
    # pull latest image for caching:
    docker pull $REGISTRY_PREFIX/$IMAGE_NAME
    # build new image (latest):
    docker build --progress=plain --no-cache -f $i -t $REGISTRY_PREFIX/$IMAGE_NAME . 2>&1 | tee ./log_$IMAGE_NAME.log
    printf "\n\nPushing $IMAGE_NAME image (latest)\n"
    # push new image as new 'latest':
    docker push "$REGISTRY_PREFIX/$IMAGE_NAME"
    # also tag it with the new tag:
    docker tag $REGISTRY_PREFIX/$IMAGE_NAME $REGISTRY_PREFIX/$IMAGE_NAME:$ALPINE_VERSION_TAG
    # and also push this (tagged) image:
    printf "\n\nPushing $IMAGE_NAME image ($ALPINE_VERSION_TAG)\n"
    docker push "$REGISTRY_PREFIX/$IMAGE_NAME:$ALPINE_VERSION_TAG"
done

printf "\n\nBuild the custom dockerfiles:\n"
cd custom_dockerfiles
./build_patient-browser.sh
cd ..

printf "\n\nTotal finish!\n"
