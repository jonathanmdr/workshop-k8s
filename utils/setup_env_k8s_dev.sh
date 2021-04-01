#!/bin/bash

set -e

KUBECTX_REPOSITORY="https://github.com/ahmetb/kubectx.git"
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

clean_kubectx_on_bashrc() {
    SYMLINKDIR=$(pkg-config --variable=completionsdir bash-completion)
    sudo rm -rf "$HOME"/.kubectx || true && \
    sudo rm "$SYMLINKDIR"/kubens || true && \
    sudo rm "$SYMLINKDIR"/kubectx || true
}

clean_kubectx_on_zshrc() {
    sudo rm -rf "$HOME"/.kubectx || true && \
    sudo rm "$HOME"/.oh-my-zsh/completions/_kubens.zsh || true && \
    sudo rm "$HOME"/.oh-my-zsh/completions/_kubectx.zsh || true
}

clean_kubectx() {
    case "$1" in
        bash)
        clean_kubectx_on_bashrc
        ;;

        zsh)
        clean_kubectx_on_zshrc
        ;;

        *)
        error_message "Invalid parameter."
        exit 1
        ;;
    esac
}

set_kubectx_on_path() {
cat << EOF >> "$HOME/.$1"
#kubectx and kubens
export PATH=\$HOME/.kubectx:\$PATH
EOF
}

update_path_if_necessary() {
    kubectx_exported=$(cat "$HOME/.$1" | grep "kubectx and kubens" || echo "$RESOURCE_NOT_FOUND")

    if [[ "$kubectx_exported" == "$RESOURCE_NOT_FOUND" ]]; then
        set_kubectx_on_path "$1"
    fi
}

install_kubectx_on_bashrc() {
    SYMLINKDIR=$(pkg-config --variable=completionsdir bash-completion) && \
    sudo ln -sf "$HOME"/.kubectx/completion/kubens.bash "$SYMLINKDIR"/kubens && \
    sudo ln -sf "$HOME"/.kubectx/completion/kubectx.bash "$SYMLINKDIR"/kubectx && \
    update_path_if_necessary "bashrc"
}

install_kubectx_on_zshrc() {
    sudo mkdir -p "$HOME"/.oh-my-zsh/completions && \
    sudo chmod -R 755 "$HOME"/.oh-my-zsh/completions && \
    sudo ln -s "$HOME"/.kubectx/completion/kubens.zsh "$HOME"/.oh-my-zsh/completions/_kubens.zsh && \
    sudo ln -s "$HOME"/.kubectx/completion/kubectx.zsh "$HOME"/.oh-my-zsh/completions/_kubectx.zsh && \
    update_path_if_necessary "zshrc"
}

install_kubectx() {    
    git clone "$KUBECTX_REPOSITORY" "$HOME"/.kubectx

    case "$1" in
        bash)
        install_kubectx_on_bashrc
        ;;

        zsh)
        install_kubectx_on_zshrc
        ;;

        *)
        error_message "Invalid parameter."
        exit 1
        ;;
    esac
}

install_kubectl() {
    sudo apt-get update && \
    sudo apt-get install -y apt-transport-https gnupg2 curl && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list && \
    sudo apt-get update && \
    sudo apt-get install -y kubectl
}

install_helm() {
    curl https://baltocdn.com/helm/signing.asc | sudo apt-key add - && \
    sudo apt-get install apt-transport-https --yes && \
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    sudo apt-get update && \
    sudo apt-get install -y helm
}

clean_minikube() {
    minikube delete && \
    sudo rm -rf /usr/local/bin/minikube
}

install_minikube() {
    sudo curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
    sudo install minikube /usr/local/bin/minikube && \
    sudo rm minikube && \
    minikube start --driver=docker && \
    minikube addons enable ingress && \
    minikube addons enable dashboard && \
    minikube addons enable metrics-server && \
    info_message "Enabled Addons: " && \
    minikube addons list | grep STATUS && minikube addons list | grep enabled && \
    info_message "Current status of Minikube: " && \
    minikube status
}

validate_resource_installation_type_not_supported() {
    resource_exists=$(snap list | grep "$1" || echo "$RESOURCE_NOT_FOUND")

    if [[ "$resource_exists" != "$RESOURCE_NOT_FOUND" ]]; then
        warning_message "'$1' installation type doesn't support, consider installing the '$1' using a package manager"
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
    resources_required=("curl" "git" "docker")

    for resource in "${resources_required[@]}"; do
        validate_mandatory_resource "$resource" && \
        validate_resource_installation_type_not_supported "$resource"
    done
}

process_docker_basic_config() {
    sudo usermod -aG docker "$USER" && \
    sudo systemctl restart docker
}

process_kubectx_installation() {
    resource=$(which kubectx || echo "$RESOURCE_NOT_FOUND")

    if [[ "$resource" == "$RESOURCE_NOT_FOUND" ]]; then
        info_message "'kubectx' not found, installation in progress..."
        install_kubectx "$1"
    else
        info_message "'kubectx' found, updating to latest version..."
        clean_kubectx "$1" && \
        install_kubectx "$1"
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
    process_docker_basic_config && \
    process_kubectx_installation "$1" && \
    process_kubectl_installation && \
    process_helm_installation && \
    process_minikube_installation && \
    sudo apt-get update && \
    info_message "Successful on the setup of K8s development environment."
}

startup_validation

if [ -z "$1" ]; then
    while [ -z "$parameter" ]
    do
        read -rp "Inform a parameter: (bash/zsh) -> " parameter
    done
else
    parameter="$1"
fi

valid_parameters=("bash" "zsh")

if [[ ! "${valid_parameters[*]}" =~ ${parameter} ]]; then
    error_message "The parameter does not valid."
    exit 1
fi

main "$parameter"
