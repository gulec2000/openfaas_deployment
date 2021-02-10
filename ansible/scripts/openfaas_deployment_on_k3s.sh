#!/bin/bash

./update_ubuntu.sh &
wait; ./ansible_setup.sh &
wait; ./copying_hosts.sh &
wait; ./docker_ins.sh &
wait; ./k3s_ins.sh &
wait; ./node-token.sh &
wait; ./faas-cli.sh &
wait; ./openfaas_ins.sh &
wait; ./update_ubuntu.sh &
