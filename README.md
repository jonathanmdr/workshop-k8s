# Workshop Introdução ao kubernetes
Workshop sobre Kubernetes, conhecendo e aplicando alguns conceitos básicos de uso do k8s.

Também conheceremos e aplicaremos os conceitos de uso do helm como gerenciador de pacotes para aplicações em cluster kubernetes.

[![node](https://img.shields.io/badge/Kubernetes-v1.24-blue.svg)](https://kubernetes.io)
[![node](https://img.shields.io/badge/Minikube-v1.25.2-blue.svg)](https://minikube.sigs.k8s.io)
[![node](https://img.shields.io/badge/Helm-v3.8.2-blue.svg)](https://helm.sh/)

## Sobre o Projeto:
O projeto consiste em dois microsserviços simples baseados no NGINX, ambos possuem uma variável de ambiente de nome `AUTHOR` onde podemos passar um nome ou algo que desejemos que seja exibido junto a mensagem de boas vindas ao acessar o serviço.

</br>

## Arquitetura do projeto:

[![node](https://github.com/jonathanmdr/workshop-k8s/blob/master/docs/architecture.png)](https://github.com/jonathanmdr/workshop-k8s/blob/master)

</br>

## Setup Ambiente:

Execute o script bash `*_setup.sh` para montar o ambiente com os recursos necessários de acordo com o seu sistema operacional.

 > :warning:  O script foi testado somente em distribuições baseadas em Ubuntu e Mac M1.

</br>

Requirements | Linux | Mac
--|--|--|
`curl` | Yes | Yes
`git` | Yes | Yes
`docker` | Yes | Yes
`brew` | No | Yes

</br>

Installation Components |
--|
`kubectx` |
`kubens` |
`kubectl` |
`helm` |
`minikube` |

</br>

#### Exemplo de uso:

##### Linux:
```bash
~$ ./linux_ubuntu_setup.sh bash #Para quem utiliza o .bashrc
~$ ./linux_ubuntu_setup.sh zsh #Para quem utiliza o .zshrc
```

##### Mac M1:
```bash
~$ ./mac_m1_setup.sh bash #Para quem utiliza o .bashrc
~$ ./mac_m1_setup.sh zsh #Para quem utiliza o .zshrc
```

##### Mac x86-64:
```bash
~$ ./mac_x86_64_setup.sh bash #Para quem utiliza o .bashrc
~$ ./mac_x86_64_setup.sh zsh #Para quem utiliza o .zshrc
```

</br>

[Setup Linux File](https://github.com/jonathanmdr/workshop-k8s/blob/master/utils/linux_ubuntu_setup.sh)
</br>
[Setup Mac M1 File](https://github.com/jonathanmdr/workshop-k8s/blob/master/utils/mac_m1_setup.sh)
</br>
[Setup Mac x86-64 File](https://github.com/jonathanmdr/workshop-k8s/blob/master/utils/mac_x86_64_setup.sh)

</br>

## Deploy:

Execute o script bash `deploy.sh` para subir a aplicação toda no cluster kubernetes local configurado anteriormente no setup.

 > :warning:  O script foi testado somente em distribuições Linux baseadas em Ubuntu e Mac M1.

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
