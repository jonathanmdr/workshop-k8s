#!/bin/bash

set -e

CONTEXT="minikube"
NAMESPACE="apps"
DEFAULT_NAMESPACE="default"
NOT_FOUND="not found"

APP1_RELEASE_NAME="app1"
APP2_RELEASE_NAME="app2"
INGRESS_RELEASE_NAME="app-ingress"

CHARTS_PATH="../helm"

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
DEFAULT=$(tput sgr0)


error_message() {
    printf "\n${RED} ERROR: ${DEFAULT}%s \n\n" "$1"
}

warning_message() {
    printf "\n${YELLOW} WARNING: ${DEFAULT}%s \n\n" "$1"
}

info_message() {
    printf "\n${GREEN} INFO: ${DEFAULT}%s \n\n" "$1"
}

validate_minikube_status() {
    is_stopped=$(minikube status | grep Stopped || echo RUNNING)

    if [[ "$is_stopped" != "RUNNING" ]]; then
        warning_message "the minikube instance is stopped, to run the minikube run the command 'minikube start'."
        exit 1
    fi
}

validate_mandatory_resource() {
    resource_exists=$(which "$1" || echo "$RESOURCE_NOT_FOUND")

    if [[ "$resource_exists" == "$RESOURCE_NOT_FOUND" ]]; then
        warning_message "'$1' not found, this is mandatory."
        exit 1
    fi
}

startup_validation() {
    resources_required=("minikube" "kubectl" "kubectx" "kubens" "helm")

    for resource in "${resources_required[@]}"; do
        validate_mandatory_resource "$resource"
    done
}

create_namespace() {
    namespace=$(kubens | grep "$NAMESPACE" || echo "$NOT_FOUND")

    if [[ "$namespace" == "$NOT_FOUND" ]]; then
        kubectl create namespace "$NAMESPACE"
    fi
}

delete_namespace() {
    kubectl delete namespace "$NAMESPACE"
}

deploy_app1() {
    helm upgrade -f ./app1/values.yaml "$APP1_RELEASE_NAME" ./app1 --install --reuse-values
}

undeploy_app1() {
    helm uninstall "$APP1_RELEASE_NAME"
}

deploy_app2() {
    helm upgrade -f ./app2/values.yaml "$APP2_RELEASE_NAME" ./app2 --install --reuse-values
}

undeploy_app2() {
    helm uninstall "$APP2_RELEASE_NAME"
}

deploy_ingress() {
    helm upgrade -f ./ingress/values.yaml "$INGRESS_RELEASE_NAME" ./ingress --install --reuse-values
}

undeploy_ingress() {
    helm uninstall "$INGRESS_RELEASE_NAME"
}

deploy() {
    validate_minikube_status && \
    pushd "$CHARTS_PATH" && \
    kubectx "$CONTEXT" && \
    create_namespace && \
    kubens "$NAMESPACE" && \
    deploy_app1 && \
    deploy_app2 && \
    deploy_ingress && \
    popd && \
    kubens "$DEFAULT_NAMESPACE" && \
    info_message "Deploy successfully"
}

undeploy() {
    validate_minikube_status && \
    kubectx "$CONTEXT" && \
    kubens "$NAMESPACE" && \
    undeploy_ingress && \
    undeploy_app2 && \
    undeploy_app1 && \
    delete_namespace && \
    warning_message "PVs are not excluded from the cluster automatically, a manual intervention is required." && \
    kubens "$DEFAULT_NAMESPACE" && \
    info_message "Undeploy successfully"
}

startup_validation

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
    error_message "The parameter does not valid."
    exit 1
    ;;
esac
