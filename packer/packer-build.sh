#!/bin/bash
set -e

if [ $# -lt 1 ]; then
  echo "${0} <path/to/container-config.yml>"
  exit 1
fi

if [ ! -f $1 ]; then
  echo "$1 does not exist"
  exit 1
fi

config=$1

container_role=`cat $config | shyaml get-value container_role`
base_image_version=`cat $config | shyaml get-value base_image_version`
base_image=`cat $config | shyaml get-value base_image`

if [ -z "${container_role}" ]; then
  echo "No container_role specified in $config."
  exit 1
fi

DEFAULT_BASE_IMAGE="alpine_base"
DEFAULT_BASE_IMAGE_VERSION="latest"

build_base_image() {
  img=$1
  img_ver=$2
  cd /vagrant/base_image/${img}
  docker build -t "${img}:${img_ver}" .
  echo "Base image built"
  cd /vagrant/packer
}

build_base_image_if_not_exists() {
  img=$1
  img_ver=$2
  echo "Looking for pre-built version of this base image: ${img}:${img_ver}"
  image_count=`docker images -q ${img}:${img_ver} | wc -l`
  if [ "${image_count}" -eq "0" ]; then
    echo "No pre-built version of base image found. Building now..."
    build_base_image "${img}" "${img_ver}"
  else
    echo "Pre-built version of base image found."
  fi
}

if [ -z ${base_image} ]; then
  base_image=$DEFAULT_BASE_IMAGE
  base_image_version=$DEFAULT_BASE_IMAGE_VERSION
  echo "No base image specified, using default: ${base_image}:${base_image_version}"
fi
build_base_image_if_not_exists "${base_image}" "${base_image_version}"
echo

echo "Starting packer build to build ${container_role}:${version}"
packer build \
  -var "ansible_host=${container_role}" \
  -var "base_image=${base_image}:${base_image_version}" \
  -var "version=${version}" \
  /vagrant/packer/packer-template.json
echo "Packer build complete"
echo
echo "Success"
echo
