# admission-control

### Certificates 
---
Because we need HTTPS to communicate with the k8s webhook.
The file script.sh has the steps in order to generate the certificates.
Review it if necessary

### Running the script
---
```bash
bash ./script.sh
```

### Problem with Docker Hub:
---
If having problems of delay of pushing images to docker hub, you can kinda set up the context of minikube to build the image in minikube cluster.

```bash
eval $(minikube docker-env)
```
Now you can execute commands in the context of minikube docker
```bash
docker ps
```
And you can run the ./script.sh again

## The solution
---
Encode the certificate in base64
```bash
cat certs/ca.crt | base64 --wrap=0
```
Exporting to a env variables
```bash
export CERT=$(cat certs/ca.crt | base64 --wrap=0)
```

TODO:
---
Using envsubst to substitute the $CERT variable inside the yaml and applying to cluster
```bash
envsubst < solution.yaml | kubectl apply -f -
```


