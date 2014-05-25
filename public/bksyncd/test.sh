#!/bin/bash

path=.
last_list=/var/log/bksync-old-list.txt
current_lsit=/tmp/bksync-current_list.txt

#write old file list
find $path -type f -follow -print > $last_list
sort $last_list -o $last_list


#write current file list
find $path -type f -follow -print > $current_list
sort $current_list -o $current_list


#diff file lists
#created file
#comm -13 <(sort $last_list) <(sort $current_list)
comm -13 <( $last_list) <(current_list) > /tmp/bksync-created.txt

#deleted file
#comm -23 <(sort $last_list) <(sort $current_list)
comm -23 <( $last_list) <($current_list) > /tmp/bksync-deleted.txt




