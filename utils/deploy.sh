#!/bin/bash

set -e

NAMESPACE="news-project"
NOT_FOUND="not found"

DATABASE_RELEASE_NAME="database-noticias"
ADMIN_RELEASE_NAME="administration-noticias"
PORTAL_RELEASE_NAME="portal-noticias"

have_minikube=$(which minikube || echo "$NOT_FOUND")

if [[ "$have_minikube" == "$NOT_FOUND" ]]; then
    echo "'minikube' not found, this is mandatory"
    exit 1
fi

have_kubectl=$(which kubectl || echo "$NOT_FOUND")

if [[ "$have_kubectl" == "$NOT_FOUND" ]]; then
    echo "'kubectl' not found, this is mandatory"
    exit 1
fi

have_kubectx=$(which kubectx || echo "$NOT_FOUND")

if [[ "$have_kubectx" == "$NOT_FOUND" ]]; then
    echo "'kubectx' not found, this is mandatory"
    exit 1
fi

have_kubens=$(which kubens || echo "$NOT_FOUND")

if [[ "$have_kubens" == "$NOT_FOUND" ]]; then
    echo "'kubens' not found, this is mandatory"
    exit 1
fi

have_helm=$(which helm || echo "$NOT_FOUND")

if [[ "$have_helm" == "$NOT_FOUND" ]]; then
    echo "'helm' not found, this is mandatory"
    exit 1
fi

create_namespace() {
    namespace=$(kubens | grep "$NAMESPACE" || echo "$NOT_FOUND")

    if [[ "$namespace" == "$NOT_FOUND" ]]; then
        kubectl create namespace "$NAMESPACE"    
    fi        
}

delete_namespace() {
    kubectl delete namespace "$NAMESPACE"
}

deploy_database() {
    helm upgrade -f ./helm/database/values.yaml "$DATABASE_RELEASE_NAME" ./helm/database --install --force
}

undeploy_database() {
    helm uninstall "$DATABASE_RELEASE_NAME"
}

deploy_administration() {
    helm upgrade -f ./helm/administration/values.yaml "$ADMIN_RELEASE_NAME" ./helm/administration --install --force
}

undeploy_administration() {
    helm uninstall "$ADMIN_RELEASE_NAME"
}

deploy_portal() {
    helm upgrade -f ./helm/portal/values.yaml "$PORTAL_RELEASE_NAME" ./helm/portal --install --force
}

undeploy_portal() {
    helm uninstall "$PORTAL_RELEASE_NAME"
}

deploy() {
    cd .. && \
    kubectx minikube && \
    create_namespace && \
    kubens "$NAMESPACE" && \
    deploy_database && \
    deploy_administration && \
    deploy_portal
}

undeploy() {
    kubectx minikube && \
    kubens "$NAMESPACE" && \
    undeploy_portal && \
    undeploy_administration && \
    undeploy_database && \
    delete_namespace && \
    printf "\n\n\033[4;33m WARNING: PVs are not excluded from the cluster automatically, a manual intervention is required. \033[0m\n\n"    
}

if [ -z "$1" ]; then
    while [ -z "$parameter" ]
    do
        read -rp "Inform a parameter: (up/down) -> " parameter        
    done
else
    parameter="$1"
fi

case "$parameter" in
    up)
    deploy
    ;;

    down)
    undeploy
    ;;

    *)
        printf "\033[4;33m WARNING: Invalid parameter \033[0m\n\n"        
        echo "Usage: './deploy.sh up' or './deploy.sh down'"
    ;;
esac
