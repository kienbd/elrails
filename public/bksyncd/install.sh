#!/bin/bash

REMOTE_SERVER=192.168.50.13
#
##Gen SSH
if [ ! -f ~/.ssh/bkswift_id_rsa ]; then
  ssh-keygen -t rsa -C "client" -N '' -f ~/.ssh/bkswift_id_rsa > /dev/null 2>&1
fi
#
##SSH agent
eval `ssh-agent`
ssh-add ~/.ssh/bkswift_id_rsa > /dev/null 2>&1
#
##Copy to Server
cd $HOME/.ssh/
curl -X POST --form "file=@bkswift_id_rsa.pub"  http://192.168.50.13/synkey
cd -
#
##Install rsync
#APT
#command -v apt >/dev/null 2>&1 && sudo apt-get install -y rsync
##Yum
#command -v yum >/dev/null 2>&1 && sudo yum install -y rsync

#Setup BkSync
mkdir -p $HOME/.bksyncd
mkdir -p $HOME/.bksyncd/{bin,log,lock,run,tmp}
touch $HOME/.bksyncd/bksync.conf

#download binary
##curl
curl -o "$HOME/.bksyncd/bin/bksync-test"  "http://$REMOTE_SERVER/bksyncd/bksync-test"
curl -o "$HOME/.bksyncd/bin/bksync" "http://$REMOTE_SERVER/bksyncd/bksync"
curl -o "$HOME/.bksyncd//bin/bksyncd" "http://$REMOTE_SERVER/bksyncd/bksyncd"

#link
ln -s $HOME/.bksyncd/bksync.conf $HOME/bksync.conf
if [ ! -f /etc/init.d/bksyncd ]; then
sudo cp $HOME/.bksyncd/bin/bksyncd /etc/init.d/bksyncd
fi
sudo chmod 777 /etc/init.d/bksyncd
chmod +x $HOME/.bksyncd/bin/bksync
chmod +x $HOME/.bksyncd/bin/bksync-test

echo "host: $REMOTE_SERVER" > $HOME/.bksyncd/bksync.conf
echo "interval: 5" >> $HOME/.bksyncd/bksync.conf
echo "path: [your-sync-path]" >> $HOME/.bksyncd/bksync.conf
echo "email: [your-email]" >> $HOME/.bksyncd/bksync.conf
echo "password: [your-password]" >> $HOME/.bksyncd/bksync.conf
#...
#echo "BKSYNCD was installed successfully"




