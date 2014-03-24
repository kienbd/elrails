#!bin/bash

echo $1 > $HOME/test.txt
echo $2 >> $HOME/test.txt
echo $3 >> $HOME/test.txt

USER=$1
CONTAINER=$2
PATH=$3

#create container
cd $HOME/elrails/vendor
/usr/bin/swift -U admin:admin -K admin -A https://127.0.0.1:8080/auth/v1.0 upload $CONTAINER welcome.txt

#create mount point
/usr/bin/mkfs.s3ql --plain swift://127.0.0.1:8080/$CONTAINER --authfile $HOME/.s3ql/authinfo --force

#mount
/bin/mkdir $PATH
/usr/bin/mount.s3ql --allow-other swift://127.0.0.1:8080/$CONTAINER $PATH --authfile $HOME/.s3ql/authinfo




