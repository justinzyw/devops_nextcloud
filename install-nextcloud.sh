#!/bin/bash

# Fetch the variables
. parm.txt

# function to get the current time formatted
currentTime()
{
  date +"%Y-%m-%d %H:%M:%S";
}

sudo docker service scale devops-nextcloud=0
sudo docker service scale devops-nextclouddb=0

echo ---$(currentTime)---populate the volumes---
#to zip, use: sudo tar zcvf devops_nextcloud_volume.tar.gz /var/nfs/volumes/devops_nextcloud*
sudo tar zxvf devops_nextcloud_volume.tar.gz -C /


echo ---$(currentTime)---create nextcloud database service---
sudo docker service create -d \
--name devops-nextclouddb \
--mount type=volume,source=devops_nextclouddb_volume,destination=/var/lib/mysql,\
volume-driver=local-persist,volume-opt=mountpoint=/var/nfs/volumes/devops_nextclouddb_volume \
--network $NETWORK_NAME \
--replicas 1 \
--constraint 'node.role == manager' \
$NEXTCLOUDDB_IMAGE


echo ---$(currentTime)---create nextcloud service---
sudo docker service create -d \
--publish $NEXTCLOUD_PORT:80 \
--name devops-nextcloud \
--mount type=volume,source=devops_nextcloud_volume,destination=/var/www/html/,\
volume-driver=local-persist,volume-opt=mountpoint=/var/nfs/volumes/devops_nextcloud_volume \
--network $NETWORK_NAME \
--replicas 1 \
--constraint 'node.role == manager' \
$NEXTCLOUD_IMAGE



sudo docker service scale devops-nextclouddb=1
sudo docker service scale devops-nextcloud=1
