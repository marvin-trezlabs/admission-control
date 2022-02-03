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

# Verify the certs folder
mkdir -p ${CERT_FOLDER}

# Create the CA key and certificate:
openssl     req         \
            -new        \
            -x509       \
            -nodes      \
            -days       365 \
            -subj       '/CN=trezlabs-admission' \
            -keyout     ${CERT_FOLDER}/ca.key \
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

# Deploy the resources to the cluster
kubectl kustomize ./k8s-resources/ | kubectl apply -f -

# # Test the server
kubectl run tmp \
  --image=curlimages/curl \
  --restart=Never \
  -it \
  --rm \
  -- \
  curl \
  --insecure \
  https://trezlabs-admission.trezlabs.svc:8443



# kubectl run tmp                 \
        # -it --rm                \
        # --image=busybox         \
        # --restart=Never         \
        # -v "./certs:/certs"     \
        # -- sh -c "wget --ca-certificate=certs/ca.crt -O - -q -T 3 https://trezlabs-admission.trezlabs.svc:8443"


# This wont work because of need the certificate

# kubectl run tmp --image=busybox --restart=Never -it --rm -- wget -O - -q -T 3 https://trezlabs-admission.trezlabs.svc:8443
