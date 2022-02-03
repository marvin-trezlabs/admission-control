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

# Create the CA key and certificate:
openssl     req         \
            -new        \
            -x509       \
            -nodes      \
            -days       365 \
            -keyout     ${CERT_FOLDER}/ca.key \
            -subj       '/CN=trezlabs-admission' \
            -out        ${CERT_FOLDER}/ca.crt

# Create the server key:
openssl     genrsa      \
            -out        ${CERT_FOLDER}/tls.key \
            2048        

# Create a certificate signing request:
openssl     req         \
            -new        \
            -subj       '/CN=trezlabs-admission.trezlabs.svc' \
            -key        ${CERT_FOLDER}/tls.key \
            -out        ${CERT_FOLDER}/tls.csr

# Create the server certificate:
openssl     x509        \
            -CAcreateserial \
            -req        \
            -days       3650 \
            -in         ${CERT_FOLDER}/tls.csr \
            -CA         ${CERT_FOLDER}/ca.crt \
            -CAkey      ${CERT_FOLDER}/ca.key \
            -out        ${CERT_FOLDER}/tls.crt

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

