#!/bin/bash

set -e

RESOURCE_NOT_FOUND="not found"

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

update_sources() {
    source ~/.bash_profile &> /dev/null && \
    source ~/.bashrc &> /dev/null && \
    source ~/.zshrc &> /dev/null
}

install_kubectx() {    
    brew install kubectx && \
    update_sources
}

install_kubectl() {
    brew install kubectl && \
    update_sources
}

install_helm() {
    brew install helm && \
    update_sources
}

clean_minikube() {
    minikube delete && \
    sudo rm -rf /usr/local/bin/minikube
}

install_minikube() {
    sudo curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64 && \
    sudo install minikube /usr/local/bin/minikube && \
    sudo rm minikube && \
    minikube start --driver=docker && \
    minikube addons enable ingress && \
    minikube addons enable dashboard && \
    minikube addons enable metrics-server && \
    info_message "Enabled Addons: " && \
    minikube addons list | grep STATUS && minikube addons list | grep enabled && \
    info_message "Current status of Minikube: " && \
    minikube status && \
    update_sources
}

validate_mandatory_resource() {
    resource_exists=$(which "$1" || echo "$RESOURCE_NOT_FOUND")

    if [[ "$resource_exists" == "$RESOURCE_NOT_FOUND" ]]; then
        warning_message "'$1' not found, this is mandatory."
        exit 1
    fi
}

startup_validation() {
    resources_required=("curl" "docker" "brew")

    for resource in "${resources_required[@]}"; do
        validate_mandatory_resource "$resource"
    done
}

process_kubectx_installation() {
    resource=$(which kubectx || echo "$RESOURCE_NOT_FOUND")

    if [[ "$resource" == "$RESOURCE_NOT_FOUND" ]]; then
        info_message "'kubectx' not found, installation in progress..."
        install_kubectx
    fi
}

process_kubectl_installation() {
    resource=$(which kubectl || echo "$RESOURCE_NOT_FOUND")

    if [[ "$resource" == "$RESOURCE_NOT_FOUND" ]]; then
        info_message "'kubectl' not found, installation in progress..."
        install_kubectl
    fi
}

process_helm_installation() {
    resource=$(which helm || echo "$RESOURCE_NOT_FOUND")

    if [[ "$resource" == "$RESOURCE_NOT_FOUND" ]]; then
        info_message "'helm' not found, installation in progress..."
        install_helm
    fi
}

process_minikube_installation() {
    resource=$(which minikube || echo "$RESOURCE_NOT_FOUND")

    if [[ "$resource" == "$RESOURCE_NOT_FOUND" ]]; then
        info_message "'minikube' not found, installation in progress..."
        install_minikube
    else
        info_message "'minikube' found, updating to latest version..."
        clean_minikube && \
        install_minikube
    fi
}

main() {
    process_kubectx_installation && \
    process_kubectl_installation && \
    process_helm_installation && \
    process_minikube_installation && \
    info_message "Successful on the setup of K8s development environment."
}

startup_validation
main
