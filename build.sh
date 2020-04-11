#!/bin/bash

# Gather parameters
if [ $# -eq 0 ];then
    perro "No argument supplied"
    exit 1
fi
build_tag=$1
build_params=$2

# Verify provided parameters
echo TAG: "${build_tag:?}"
echo PARAMS: "${build_params}"

# Exit on error
set -e

docker buildx build --progress plain --platform linux/arm/v6,linux/arm64,linux/386,linux/amd64 --tag ${build_tag} ${build_params} .
