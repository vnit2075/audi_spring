#!/bin/bash

# Default to standard user kubeconfig or jenkins kubeconfig if configured
KUBECONFIG=${KUBECONFIG:-$HOME/.kube/config}
if [ ! -f "$KUBECONFIG" ] && [ -f "/var/lib/jenkins/kubeconfig.yml" ]; then
    KUBECONFIG="/var/lib/jenkins/kubeconfig.yml"
fi

if [ "$1" == "deploy" ]; then
    echo "Deploying MySQL in namespace 'audi-showroom'..."
    kubectl --kubeconfig="$KUBECONFIG" apply -f k8s/namespace.yml
    kubectl --kubeconfig="$KUBECONFIG" apply -f k8s/mysql/mysql-statefulset.yml
    kubectl --kubeconfig="$KUBECONFIG" apply -f k8s/mysql/mysql-service.yml
    echo "MySQL deploy process completed."

elif [ "$1" == "destroy" ]; then
    echo "Destroying MySQL in namespace 'audi-showroom'..."
    kubectl --kubeconfig="$KUBECONFIG" delete -f k8s/mysql/mysql-service.yml --ignore-not-found
    kubectl --kubeconfig="$KUBECONFIG" delete -f k8s/mysql/mysql-statefulset.yml --ignore-not-found
    echo "MySQL destroy process completed."

else
    echo "Usage: $0 deploy | destroy"
fi
