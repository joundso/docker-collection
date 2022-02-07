#!/bin/bash
set -e 
set -o pipefail

## Get version tag and registry-prefix from .env:
source ./.env

DIRECTORY=./dockerfiles

for i in $DIRECTORY/*.dockerfile; do
    ## i = ./dockerfiles/alpine-bash-curl-ssl.dockerfile
    ## Remove path (to get suffix = alpine-bash-curl-ssl.dockerfile):
    suffix=${i##*/}
    ## ... and file ending  (to get IMAGE_NAME = alpine-bash-curl-ssl):
    IMAGE_NAME="${suffix%.*}"

    ## Get base-image from filename (to get BASE_IMAGE = BASE_IMAGE):
    BASE_IMAGE="${IMAGE_NAME%%-*}"

    ## Create the name of the variable to load from .env:
    variable_name="${BASE_IMAGE^^}_VERSION_TAG"

    ## Read the image tag from .env for the given variable_name:
    BASE_IMAGE_TAG=${!variable_name}

    # printf "\n i = $i\n"
    # printf "\n suffix = $suffix\n"
    # printf "\n IMAGE_NAME = $IMAGE_NAME\n"
    # printf "\n BASE_IMAGE = $BASE_IMAGE\n"
    # printf "\n variable_name = $variable_name\n"
    # printf "\n BASE_IMAGE_TAG = $BASE_IMAGE_TAG\n"

    if [ -z "${BASE_IMAGE_TAG}" ]; then
        echo "Error: Couldn't find an image tag for base image ${BASE_IMAGE} in the '.env' file! Please provide a variable '${variable_name}' there with the image tag."
        exit 1
    fi

    printf "\n\n##################################\n"
    printf "Building $REGISTRY_PREFIX/$IMAGE_NAME:$BASE_IMAGE_TAG"
    printf "\n##################################\n"

    printf "\n\nPlease insert your login credentials to registry: $REGISTRY_PREFIX ...\n"
    docker login

    printf "\nPulling cached $IMAGE_NAME image\n"
    ## Pull latest image for caching:
    docker pull $REGISTRY_PREFIX/$IMAGE_NAME
    ## Build new image (latest):
    docker build \
        --progress=plain \
        --no-cache=true \
        --label "org.label-schema.name=joundso/$IMAGE_NAME" \
        --label "org.label-schema.vsc-url=https://github.com/joundso/docker-collection/blob/master/dockerfiles/$suffix" \
        --label "org.label-schema.vcs-ref=$(git rev-parse HEAD)" \
        --label "org.label-schema.version=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
        --build-arg "BASE_IMAGE_TAG=${BASE_IMAGE_TAG}" \
        -f $i \
        -t $REGISTRY_PREFIX/$IMAGE_NAME . 2>&1 | tee ./log_$IMAGE_NAME.log
    
    printf "\n\nPushing $IMAGE_NAME image (latest)\n"
    ## Push new image as new 'latest':
    docker push "$REGISTRY_PREFIX/$IMAGE_NAME"
    
    ## Also tag it with the new tag:
    docker tag $REGISTRY_PREFIX/$IMAGE_NAME $REGISTRY_PREFIX/$IMAGE_NAME:$BASE_IMAGE_TAG
    
    ## And also push this (tagged) image:
    printf "\n\nPushing $IMAGE_NAME image ($BASE_IMAGE_TAG)\n"
    docker push "$REGISTRY_PREFIX/$IMAGE_NAME:$BASE_IMAGE_TAG"
done

printf "\n\nBuild the custom dockerfiles:\n"
## Patient browser:
cd custom_dockerfiles
./build_patient-browser.sh
cd ..

printf "\n\nTotal finish!\n"
