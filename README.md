# kubernetes
Workshop sobre Kubernetes, conhecendo e aplicando alguns conceitos básicos de uso do k8s.

Também conheceremos e aplicaremos os conceitos de uso do helm como gerenciador de pacotes para aplicações em cluster kubernetes.

[![node](https://img.shields.io/badge/Kubernetes-stable-blue.svg)](https://kubernetes.io)
[![node](https://img.shields.io/badge/Minikube-v1.18.1-blue.svg)](https://minikube.sigs.k8s.io)
[![node](https://img.shields.io/badge/Helm-v3.5.3-blue.svg)](https://helm.sh/)

## Sobre o Projeto:
O projeto consiste em dois microsserviços simples baseados no NGINX, ambos possuem uma variável de ambiente de nome `AUTHOR` onde podemos passar um nome ou algo que desejemos que seja exibido junto a mensagem de boas vindas ao acessar o serviço.

</br>

## Setup Ambiente Linux:

Execute o script bash `setup_env_k8s_dev.sh` para montar o ambiente com os recursos necessários.

</br>

Pré-requisitos |
--|
`curl` |
`git` |
`docker` |

</br>

Componentes da instalação |
--|
`kubectx` |
`kubens` |
`kubectl` |
`helm` |
`minikube` |

</br>

#### Exemplo de uso:

```bash
~$ chmod +x setup_env_k8s_dev.sh
~$ ./setup_env_k8s_dev.sh bash #Para quem utiliza o .bashrc
~$ ./setup_env_k8s_dev.sh zsh #Para quem utiliza o .zshrc
```

</br>

[Setup Linux File](https://github.com/jonathanmdr/workshop-k8s/blob/master/utils/setup_env_k8s_dev.sh)

</br>

## Deploy:

Execute o script bash `deploy.sh` para subir a aplicação toda no cluster kubernetes local configurado anteriormente no setup.

</br>

#### Exemplo de uso:

```bash
~$ chmod +x deploy.sh
~$ ./deploy.sh
```

 > O deploy da aplicação considera que exista um DNS válido informado na propriedade `host` nas regras de especificações do `Ingress`, para simular o comportamento em ambiente local com o `Minikube` é necessário mapear o `IP` do `Minikube` no arquivo localizado em `\etc\hosts`.
 > O `IP` pode ser obtido através do seguinte comando: `minikube ip`.

</br>

[Deploy Application File](https://github.com/jonathanmdr/workshop-k8s/blob/master/utils/deploy.sh)