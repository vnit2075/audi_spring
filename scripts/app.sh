#!/bin/bash

# Default to standard user kubeconfig or jenkins kubeconfig if configured
KUBECONFIG=${KUBECONFIG:-$HOME/.kube/config}
if [ ! -f "$KUBECONFIG" ] && [ -f "/var/lib/jenkins/kubeconfig.yml" ]; then
    KUBECONFIG="/var/lib/jenkins/kubeconfig.yml"
fi

NAMESPACE="audi-showroom"
SERVICE_NAME="audi-showroom"

if [ "$1" == "deploy" ]; then
    IMAGE="$2"
    if [ -z "$IMAGE" ]; then
        echo "Usage: $0 deploy <image-name:tag>"
        exit 1
    fi

    # Determine current active deployment color from Service selector
    ACTIVE=$(kubectl --kubeconfig="$KUBECONFIG" get svc "$SERVICE_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.selector.color}' 2>/dev/null)

    if [ "$ACTIVE" == "blue" ]; then
        TARGET="green"
    else
        # If no active color is found (first deployment), default to blue
        TARGET="blue"
        ACTIVE="none"
    fi

    echo "Current Active Color: $ACTIVE"
    echo "Deploying new version to target: $TARGET"
    echo "Using Docker image: $IMAGE"

    # Ensure namespace exists
    kubectl --kubeconfig="$KUBECONFIG" apply -f k8s/namespace.yml

    # Replace image dynamically and apply deployment
    sed "s|audi/audi-showroom:latest|$IMAGE|g" k8s/app/deployment-$TARGET.yml | kubectl --kubeconfig="$KUBECONFIG" apply -f -

    # Wait for rollout to complete successfully before switching traffic
    echo "Awaiting deployment rollout status for: $SERVICE_NAME-$TARGET..."
    kubectl --kubeconfig="$KUBECONFIG" rollout status deployment/"$SERVICE_NAME-$TARGET" -n "$NAMESPACE"

    # Patch the service selector to route traffic to the newly deployed pods
    echo "Updating Service endpoint to point to: color=$TARGET..."
    kubectl --kubeconfig="$KUBECONFIG" patch svc "$SERVICE_NAME" -n "$NAMESPACE" \
      -p "{\"spec\":{\"selector\":{\"app\":\"$SERVICE_NAME\",\"color\":\"$TARGET\"}}}"

    echo "Blue-Green deployment swap completed successfully! Active version is now $TARGET."

elif [ "$1" == "destroy" ]; then
    COLOR="$2"
    if [ -z "$COLOR" ] || [[ "$COLOR" != "blue" && "$COLOR" != "green" ]]; then
        echo "Usage: $0 destroy <blue|green>"
        exit 1
    fi

    echo "Decommissioning application deployment: $SERVICE_NAME-$COLOR..."
    kubectl --kubeconfig="$KUBECONFIG" delete deployment "$SERVICE_NAME-$COLOR" -n "$NAMESPACE" --ignore-not-found
    echo "Deployment destroyed."

else
    echo "Usage:"
    echo "  $0 deploy <image-name:tag>"
    echo "  $0 destroy <blue|green>"
fi
