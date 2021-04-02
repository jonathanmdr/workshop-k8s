# Workshop Introdução ao kubernetes
Workshop sobre Kubernetes, conhecendo e aplicando alguns conceitos básicos de uso do k8s.

Também conheceremos e aplicaremos os conceitos de uso do helm como gerenciador de pacotes para aplicações em cluster kubernetes.

[![node](https://img.shields.io/badge/Kubernetes-stable-blue.svg)](https://kubernetes.io)
[![node](https://img.shields.io/badge/Minikube-v1.18.1-blue.svg)](https://minikube.sigs.k8s.io)
[![node](https://img.shields.io/badge/Helm-v3.5.3-blue.svg)](https://helm.sh/)

## Sobre o Projeto:
O projeto consiste em dois microsserviços simples baseados no NGINX, ambos possuem uma variável de ambiente de nome `AUTHOR` onde podemos passar um nome ou algo que desejemos que seja exibido junto a mensagem de boas vindas ao acessar o serviço.

</br>

## Arquitetura do projeto:

[![node](https://github.com/jonathanmdr/workshop-k8s/blob/master/docs/architecture.png)](https://github.com/jonathanmdr/workshop-k8s/blob/master)

</br>

## Setup Ambiente Linux:

Execute o script bash `setup_env_k8s_dev.sh` para montar o ambiente com os recursos necessários.

 > :warning:  O script foi testado somente em distribuições baseadas no Ubuntu.

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
~$ ./setup_env_k8s_dev.sh bash #Para quem utiliza o .bashrc
~$ ./setup_env_k8s_dev.sh zsh #Para quem utiliza o .zshrc
```

</br>

[Setup Linux File](https://github.com/jonathanmdr/workshop-k8s/blob/master/utils/setup_env_k8s_dev.sh)

</br>

## Deploy:

Execute o script bash `deploy.sh` para subir a aplicação toda no cluster kubernetes local configurado anteriormente no setup.

 > :warning:  O script foi testado somente em distribuições baseadas no Ubuntu.

</br>

#### Exemplo de uso:

```bash
~$ ./deploy.sh up #Para fazer o deploy da aplicação
~$ ./deploy.sh down #Para fazer o undeploy da aplicação
```

 > O deploy da aplicação considera que exista um DNS válido informado na propriedade `host` nas regras de especificações do `Ingress`, para simular o comportamento em ambiente local com o `Minikube` é necessário mapear o `IP` do `Minikube` no arquivo localizado em `/etc/hosts`.
 > O `IP` pode ser obtido através do seguinte comando: `minikube ip`.
 > O nosso DNS que deve ser configurado é: `workshop-k8s`.

</br>

[Deploy Application File](https://github.com/jonathanmdr/workshop-k8s/blob/master/utils/deploy.sh)