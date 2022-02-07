# Create CA Key
openssl genrsa -aes256 -out ca.key.pem 2048

# CA certificate
openssl req \
        -new \
        -x509 \
        -subj "/CN=trezlabs-admision" \
        -extensions v3_ca \
        -days 3650 \
        -key ca.key.pem \
        -sha256 \
        -out ca.pem \
        -config test.cnf

# Generate Key Pair
openssl genrsa -out tls.key.pem 2048

# Create Cert Signing Request
openssl req \
        -subj "/CN=trezlabs-admission.trezlabs.svc" \
        -extensions v3_req \
        -sha256 \
        -new \
        -key tls.key.pem \
        -out tls.csr

openssl x509 \
        -req \
        -extensions v3_req \
        -days 3650 \
        -sha256 \
        -in tls.csr \
        -CA ca.pem \
        -CAkey ca.key.pem \
        -CAcreateserial \
        -out tls.crt \
        -extfile test.cnf
