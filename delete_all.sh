#!/usr/bin/env bash

# Delete OpenIM Server
echo "Deleting OpenIM Server..."
cd open-im-server
./kubectl_stop_all.sh
kubectl delete -f ./ingress.yaml --ignore-not-found=true
cd ..

# Delete zookeeper
echo "Deleting zookeeper..."
helm uninstall zookeeper --namespace openim-infra --ignore-not-found
kubectl delete -f ./zookeeper/sc.yaml --ignore-not-found=true

# Delete kafka
echo "Deleting kafka..."
helm uninstall kafka --namespace openim-infra --ignore-not-found
kubectl delete -f ./kafka/sc.yaml --ignore-not-found=true

# Delete minio
echo "Deleting minio..."
helm uninstall minio --namespace openim-infra --ignore-not-found
kubectl delete -f ./minio/sc.yaml --ignore-not-found=true

# Delete redis cluster
echo "Deleting redis cluster..."
helm uninstall redis-cluster -n openim-infra --ignore-not-found
kubectl delete -f ./redis/sc.yaml --ignore-not-found=true

# Delete mongodb
echo "Deleting mongodb..."
helm uninstall mongodb --namespace openim-infra --ignore-not-found
kubectl delete -f ./mongodb/sc.yaml --ignore-not-found=true

# Delete mysql
echo "Deleting mysql..."
helm uninstall mysql --namespace openim-infra --ignore-not-found
kubectl delete -f ./mysql/sc.yaml --ignore-not-found=true

# Delete etcd
echo "Deleting etcd..."
helm uninstall etcd --namespace openim-infra --ignore-not-found
kubectl delete -f ./etcd/sc.yaml --ignore-not-found=true

# Delete NFS provisioner
# echo "Deleting NFS provisioner..."
# helm uninstall nfs-subdir-external-provisioner --ignore-not-found
# cd nfs-subdir-external-provisioner
# kubectl delete -f ./templates/storageclass.yaml --ignore-not-found=true
# cd ..
echo "NFS provisioner deletion skipped - using local-path storage on node3"

# Delete namespace openim-infra
echo "Deleting namespace openim-infra..."
kubectl delete namespace openim-infra --ignore-not-found=true

# Delete namespace openim
echo "Deleting namespace openim..."
kubectl delete namespace openim --ignore-not-found=true

echo "Deletion complete. Verify with: kubectl get all --all-namespaces"
