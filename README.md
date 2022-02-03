# admission-control

### Certificates 
---
Because we need HTTPS to communicate with the k8s webhook.
The file script.sh has the steps in order to generate the certificates.
Review it if necessary

### Running the script for creating the cert and build the image
---
```bash
bash ./script.sh
```

### Exporting the cert to a variable
```bash
export CERT=$(cat certs/ca.crt | base64 --wrap=0)
```
### Aplying the js app deployment config files
```bash
kubectl kustomize ./k8s-resources/ | kubectl apply -f -
```
### Aplying the ValidationControlConfig
envsubst is for sustituying the ENV $CERT variable on the yaml
```bash
envsubst < ./k8s-resources/solution.yaml | kubectl apply -f -
```
### View the server logs
Now you can create a secret (default expected name: test-chart-2-crt-secret) and see the events.
```bash
kubectl logs $(kubectl get pod -n trezlabs -o jsonpath="{.items[0].metadata.name}") -n trezlabs --follow
```

<!-- ### Problem with Docker Hub:
---
If having problems of delay of pushing images to docker hub, you can kinda set up the context of minikube to build the image in minikube cluster.

```bash
eval $(minikube docker-env)
```
Now you can execute commands in the context of minikube docker
```bash
docker ps
```
And you can run the ./script.sh again -->

<!-- ## The solution
---
Encode the certificate in base64
```bash
cat certs/ca.crt | base64 --wrap=0
```

Exporting to a env variables
```bash
export CERT=$(cat certs/ca.crt | base64 --wrap=0)
```

---
Using envsubst to substitute the $CERT variable inside the yaml and applying to cluster
```bash
envsubst < solution.yaml | kubectl apply -f -
envsubst < ./k8s-resources/solution.yaml | kubectl kustomize ./k8s-resources/ | kubectl apply -f -

``` -->

---

### KNOWN ISSUE:
Seems like GO doesnt allow legacy CN certificates and expects a SAN format certificate.
In order to fix this, we will temporally disable this debug option.
We later research about SAN certificates.

To do that, add the following content to: /etc/kubernetes/manifests/kube-apiserver.yaml
Important: In the IMAGE section of the yaml
(Rename the kube-apiserver.yaml file if necessary)
```bash
name: kube-apiserver
env:
- name: GODEBUG
    value: "x509ignoreCN=0"
```