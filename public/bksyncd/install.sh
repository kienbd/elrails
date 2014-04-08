#!/bin/bash

#REMOTE_SERVER=10.211.55.5
#
##Gen SSH
#ssh-keygen -t rsa -C "client" -N '' -f ~/.ssh/bkswift_id_rsa
#
##SSH agent
#eval `ssh-agent`
#ssh-add ~/.ssh/bkswift_id_rsa
#
##Copy to Server
#cat ~/.ssh/bkswift_id_rsa.pub | ssh $REMOTE_SERVER 'cat - >> ~/.ssh/authorized_keys2;chmod 44 ~/.ssh/authorized_keys2'
#ssh REMOTE_SERVER 'chmod 700 .ssh'
#
##Install rsync

#APT
command -v apt >/dev/null 2>&1 && apt-get install -y rsync
#Yum
command -v yum >/dev/null 2>&1 && yum install -y rsync

#Setup BkSync

#download binary
mkdir -p /tmp/bksync-service
#curl
curl -o /tmp/bksync-service/bksync-test  http://$REMOTE_SERVER:3000/bksync/bksync-test
curl -o /tmp/bksync-service/bksync http://$REMOTE_SERVER:3000/bksync/bksync
curl -o /tmp/bksync-service/bksyncd http://$REMOTE_SERVER:3000/bksync/bksyncd
echo "host: $REMOTE_SERVER" > /tmp/bksync-service/bksync.conf
echo "inverval: 30" >> /tmp/bksync-service/bksync.conf
#...

#configure
cp /tmp/bksync-service/bksync-test /usr/local/bin/bksync-test
cp /tmp/bksync-service/bksync /usr/local/bin/bksync
cp /tmp/bksync-service/bksyncd /etc/init.d/bksyncd
cp /tmp/bksync-service/bksync.conf /etc/bksync.conf
rm -rf /tmp/bksync-service
chmod +x /usr/local/bin/bksync-test
chmod +x /usr/local/bin/bksync
chmod +x /etc/init.d/bksyncd


