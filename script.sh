#!/bin/bash

# start minikube if required
# minikube start

# Install telepresence
# curl -s https://packagecloud.io/install/repositories/datawireio/telepresence/script.deb.sh | sudo bash
# sudo apt install -y --no-install-recommends telepresence

# GCP Hack
# rm -rf ~/.docker

# Define the certificates folder
export CERT_FOLDER=${PWD}/certs

# Delete certs
rm -rf $CERT_FOLDER

# Verify the certs folder
mkdir -p ${CERT_FOLDER}

# Create CA Key
openssl genrsa -aes256 -out ${CERT_FOLDER}/ca.key 2048

# CA certificate
openssl req \
        -new \
        -x509 \
        -subj "/CN=trezlabs-admision" \
        -extensions v3_ca \
        -days 3650 \
        -key ${CERT_FOLDER}/ca.key \
        -sha256 \
        -out ${CERT_FOLDER}/ca.crt \
        -config san-config/san.cnf

# Generate Key Pair
openssl genrsa -out ${CERT_FOLDER}/tls.key 2048

# Create Cert Signing Request
openssl req \
        -subj "/CN=trezlabs-admission.trezlabs.svc" \
        -extensions v3_req \
        -sha256 \
        -new \
        -key ${CERT_FOLDER}/tls.key \
        -out ${CERT_FOLDER}/tls.csr

# Create Certificate
openssl x509 \
        -req \
        -extensions v3_req \
        -days 3650 \
        -sha256 \
        -in ${CERT_FOLDER}/tls.csr \
        -CA ${CERT_FOLDER}/ca.crt \
        -CAkey ${CERT_FOLDER}/ca.key \
        -CAcreateserial \
        -out ${CERT_FOLDER}/tls.crt \
        -extfile san-config/san.cnf

# Copy the certificates to the K8S-resources folder so it can be 
# used as secret for the deploymnets
cp -R ${CERT_FOLDER} ./k8s-resources
cp -R ${CERT_FOLDER} ./app

# Build the required image
docker-compose build --no-cache
# Push the image to docker-hub
docker-compose push

# delete ns
# kubectl delete ns trezlabs

