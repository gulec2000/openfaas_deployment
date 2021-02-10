#!/bin/bash

apt install software-properties-common
apt install ansible
cat << 'EOF' >> /etc/ansible/hosts
[all]
159.69.209.165
157.90.27.66
78.47.152.129

[master]
159.69.209.165
[workers]
157.90.27.66     
78.47.152.129
EOF
ufw allow 6443/tcp
ufw allow 443/tcp
