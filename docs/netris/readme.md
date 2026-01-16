# Install lvp

```
kubectl create ns lvp
kubectl label node kfcz07 local-volume-provisioner=enabled
helm install lvp https://binary.mirantis.com/bm/helm/local-volume-provisioner-2.5.0-mcp.tgz --namespace lvp -f lvp.yaml
```

# Install metallb

```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.3/config/manifests/metallb-native.yaml
```

# Install netris controller
```
git clone https://github.com/netrisai/charts netris-charts -b netris-controller-2.8.0
helm upgrade --install netris-controller netris-charts/charts/netris-controller   --namespace netris-controller   -f nc.yaml


# Install netris operator
```
helm upgrade --install netris-operator -f no.yaml ~/Work/Projects/netris-operator/deploy/charts/netris-operator
```

# Expose service via minikube
```
minikube -n netris-controller service netris-controller-web-service-frontend --url
```


# Build controller
export i=2; docker rm $((i - 1)); docker build . -t jumpojoy/unified-fabric-operator:vs${i} && docker push jumpojoy/unified-fabric-operator:vs${i}

make manifests; kubectl apply -k config/crd
export FABRIC_BACKEND=netris; export IPAM_BACKEND=metal3; make run
