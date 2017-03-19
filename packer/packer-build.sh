#!/bin/bash

if [ $# -lt 1 ]; then
    echo "${0} <container_role> [base_image]"
    exit 1
fi

container_role=$1
base_image=${2:-"ubuntu:16.04"}

packer build -var "ansible_host=${container_role}" -var "base_image=${base_image}" packer-template.json
