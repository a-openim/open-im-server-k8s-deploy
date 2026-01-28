#!/usr/bin/env bash

# Create namespace openim
kubectl create namespace openim --dry-run=client -o yaml | kubectl apply -f -

# Create namespace openim-infra
kubectl create namespace openim-infra --dry-run=client -o yaml | kubectl apply -f -

# Install NFS provisioner
echo "Installing NFS provisioner..."
if ! command -v helm &> /dev/null; then
    echo "Helm is not installed. Please install Helm first."
    exit 1
fi
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update
helm pull nfs-subdir-external-provisioner/nfs-subdir-external-provisioner
tar -zxvf nfs-subdir-external-provisioner-*.tgz
cd nfs-subdir-external-provisioner
# Modify values.yaml for Aliyun mirror (assuming NFS server and path need to be set manually)
sed -i '' 's|repository:.*|repository: registry.cn-hangzhou.aliyuncs.com/lzf-k8s/k8s-nfs-storage|' values.yaml
sed -i '' 's|tag:.*|tag: 1.0.0|' values.yaml
# Note: Set NFS server and path in values.yaml or via --set
helm install nfs-subdir-external-provisioner . \
    --set nfs.server=10.88.88.13 \
    --set nfs.path=/k8s/storage/nfs -f values.yaml
cd ..

# Deploy etcd
echo "Deploying etcd..."
kubectl apply -f ./etcd/sc.yaml
helm install etcd ./etcd --namespace openim-infra

# Deploy mysql
echo "Deploying mysql..."
kubectl apply -f ./mysql/sc.yaml
helm install mysql ./mysql --namespace openim-infra

# Deploy mongodb
echo "Deploying mongodb..."
kubectl apply -f ./mongodb/sc.yaml
helm install mongodb ./mongodb --namespace openim-infra

# Deploy redis cluster
echo "Deploying redis cluster..."
kubectl apply -f ./redis/sc.yaml
helm install redis-cluster -f ./redis/values.yaml bitnami/redis-cluster -n openim-infra

# Deploy minio
echo "Deploying minio..."
kubectl apply -f ./minio/sc.yaml
helm install minio ./minio --namespace openim-infra

# Deploy kafka
echo "Deploying kafka..."
kubectl apply -f ./kafka/sc.yaml
helm install kafka ./kafka --namespace openim-infra

# Deploy zookeeper
echo "Deploying zookeeper..."
kubectl apply -f ./zookeeper/sc.yaml
helm install zookeeper ./zookeeper --namespace openim-infra

# Deploy OpenIM Server
echo "Deploying OpenIM Server..."
cd open-im-server
./kubectl_start_all.sh
kubectl apply -f ./ingress.yaml
cd ..

echo "Deployment complete. Verify with: kubectl -n openim get pods"