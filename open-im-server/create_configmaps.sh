#!/bin/bash

# Create namespace for open-IM project
kubectl get namespace openim >/dev/null 2>&1 || kubectl create namespace openim

# Create configmaps from config files
kubectl delete configmap openim-config -n openim --ignore-not-found
kubectl -n openim create configmap openim-config --from-file=config.yaml
if [ -f notification.yaml ]; then
    kubectl delete configmap openim-notification-config -n openim --ignore-not-found
    kubectl -n openim create configmap openim-notification-config --from-file=notification.yaml
else
    echo "notification.yaml not found, skipping openim-notification-config creation"
fi

# Apply limitRange
kubectl apply -f limitRange.yaml -n openim

# View configmaps
kubectl -n openim get configmap