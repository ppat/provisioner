#!/bin/bash

if [ $# -lt 1 ]; then
    echo "${0} <container_role> [version] [base_image] [tags]"
    exit 1
fi

container_role=$1
version=${2:-"latest"}
base_image=$3
tags=$4

DEFAULT_BASE_IMAGE="alpine_base"
DEFAULT_TAGS="alpine"

build_base_image() {
  img=$1
  cd /vagrant/base_image/${img}
  docker build -t "${img}" .
  cd /vagrant/packer
}

build_base_image_if_not_exists() {
  img=$1
  echo "Looking for pre-built version of this base image..."
  image_count=`docker images -q ${img} | wc -l`
  if [ "${image_count}" -eq "0" ]; then
    echo "No pre-built version of default base image found. Building now..."
    build_base_image "${img}"
  else
    echo "Pre-built version of default base image found."
  fi
}

if [ -z ${base_image} ]; then
  base_image=$DEFAULT_BASE_IMAGE
  tags=$DEFAULT_TAGS
  echo "No base image specified, using default: ${base_image}"
fi
build_base_image_if_not_exists "${base_image}"

packer build \
  -var "ansible_host=${container_role}" \
  -var "base_image=${base_image}" \
  -var "version=${version}" \
  -var "tags=${tags}" \
  packer-template.json
