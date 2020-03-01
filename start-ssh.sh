#!/bin/sh

if [ ! -f /init ]; then
    echo "Creating keys for SSH server..."
    ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
    ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
    touch /init
fi

echo "Starting SSH server"
echo "Connect with 'ssh -X -p 2222 root@[CONTAINER HOST]' to export X-Window."
/usr/sbin/sshd -D
