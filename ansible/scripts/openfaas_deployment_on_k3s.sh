#!/bin/bash

bash /root/openfaas_deployment/ansible/scripts/update_ubuntu.sh &
wait; bash /root/openfaas_deployment/ansible/scripts/ansible_setup.sh &
wait; bash /root/openfaas_deployment/ansible/scripts/copying_hosts.sh &
wait; bash /root/openfaas_deployment/ansible/scripts/docker_ins.sh &
wait; bash /root/openfaas_deployment/ansible/scripts/k3s_ins.sh &
wait; bash /root/openfaas_deployment/ansible/scripts/node-token.sh &
wait; bash /root/openfaas_deployment/ansible/scripts/faas-cli.sh &
wait; bash /root/openfaas_deployment/ansible/scripts/openfaas_ins.sh &
wait; bash /root/openfaas_deployment/ansible/scripts/update_ubuntu.sh &
wait; echo "export OPENFAAS_URL=http://159.69.209.165:31112" >> .bashrc
