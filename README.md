# OpenFaas Bereitstellung auf k3s cluster

## Eintreten Sie die Master und Worker Nodes mit ssh
```
ssh master@master_IP
ssh worker-1@worker_1_IP
ssh worker-2@worker-2_IP
```

## Installierung Ansible auf Master-Node

```
$ sudo apt update
$ sudo apt install software-properties-common
$ sudo apt install ansible
```
* **Konfigurierung Hosts file auf /etc/ansible**

```
[master]
159.69.209.165 ansible_user=master      

[workers]
157.90.27.66 ansible_user=worker-1     
78.47.152.129 ansible_user=worker-2    
```
* **Erstellung SSH-Key für die SSH Verbindung**

```
ssh-keygen
```
* **Kopierung id_rsa.pub auf Worker-Nodes**
* *Nachdem Kopierung des Inhalts von id_rsa.pub in Master-node;*
    - Erstellen Sie einen id_rsa.pub auf /root/.ssh und kopieren Sie den Inhalt auf id_rsa.pub 
    - Kopieren Sie es auch auf /root/.ssh/authorized_keys

```
vi /root/.ssh/id_rsa.pub 
vi /root/.ssh/authorized_keys
```
* **Verifizierung der Kommunizierung zwischen Master- und Worker-Node**
```
ansible all --list-hosts
```
*Output ist wie unten:*
```
hosts (3):
    159.69.209.165
    157.90.27.66
    78.47.152.129
```
```
ansible all -m ping
```
*Output ist wie unten:*
```
159.69.209.165 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
157.90.27.66 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
78.47.152.129 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

## k3s Installation auf Ubuntu
* **Aktuelliesierung der Ubuntu** 
```
apt update
apt -y upgrade
systemctl reboot
```
* **Map die hostnames auf jede Node**
- *Hinzufüge die Hostnames auf /etc/hosts*
```
vi /etc/hosts
159.69.209.165 master.12259.sva.dev master
157.90.27.66 worker-1.12259.sva.dev worker-1
78.47.152.129 worker-2.12259.sva.dev worker-2
```
* **Installierung Docker auf Ubuntu**
- *Hinzufügen Docker APT Repo*
```
apt update
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
```
- *Installierug Docker CE auf Ubuntu*
```
apt update
apt install docker-ce -y
systemctl start docker
systemctl enable docker
systemctl status docker
```
- *wenn nicht root:*
```
sudo usermod -aG docker ${USER}
newgrp docker
```
* **Einrichtung die Master k3s Node**
```
curl -sfL https://get.k3s.io | sh -s
systemctl status k3s
```
* *Kontrollierung die Master Node*
```
kubectl get nodes -o wide
```
* *Zulassung der Ports 6443 und 443 auf Firewall*
```
ufw allow 6443/tcp
ufw allow 443/tcp
```
* *Extrahierung eines Tokens aus dem Master*
```
cat /var/lib/rancher/k3s/server/node-token
```
- **Token ist wie das:*
```
K1078f2861628c95aa328595484e77f831adc3b58041e9ba9a8b2373926c8b034a3::server:417a7c6f46330b601954d0aaaa1d0f5b
```
* **Installierung k3s Worker-Nodes und Verbindung mit dem Master**
Machen Sie das auf Worker-Nodes
- *Hinzufügen Sie IP(<master_IP>) und Token(<join_token>) von Master-Node*
- *Machen Sie das nochmals für noch zweite Node*
```
curl -sfL http://get.k3s.io | K3S_URL=https://<master_IP>:6443 K3S_TOKEN=<join_token> sh -s agent
```
* **Verifizierung k3s Worker-Node**
```
systemctl status k3s-agent
kubectl get nodes -o wide
```
## Installierung faas-cli
```
curl -sSL https://cli.openfaas.com | sh
```
- *Verifizierung faas-cli*
```
faas-cli version
```
## Installierung OpenFaaS mit Helm
* **Installierung Helm** und **Erstellung Namespaces (openfaas und openfaas-fn)**

```
curl -sSLf https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml
helm repo add openfaas https://openfaas.github.io/faas-netes/
helm repo update \
 && helm upgrade openfaas --install openfaas/openfaas \
    --namespace openfaas  \
    --set functionNamespace=openfaas-fn \
    --set generateBasicAuth=true \
    --set openfaasPRO=false
    --set ingress.enabled=true
```
* *Rufen Sie die OpenFaaS-Anmeldeinformationen mit ab*
```
PASSWORD=$(kubectl -n openfaas get secret basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode) && \
echo "OpenFaaS admin password: $PASSWORD"
```
* *Verifizierung der Installation von OpenFaas*
```
kubectl -n openfaas get deployments -l "release=openfaas, app=openfaas"
```
* *Stellen Sie die KUBECONFIG-Env ein*
```
export OPENFAAS_URL=http://<master_IP>:31112
```
* *Login mit der CLI und überprüfen Sie die Konnektivität:*
```
echo -n $PASSWORD | faas-cli login -g $OPENFAAS_URL -u admin --password-stdin
faas-cli version
```