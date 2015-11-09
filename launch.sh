#! /bin/bash

./cleanup.sh

#declare an array in bash
declare -a instanceARR
mapfile -t instanceARR < < (aws ec2 run-instances --image-id ami-d05e75b8 --count $1 --instance-type t2.micro --key-name itmo444-virtualbox --security-group-ids sg- --subnet-id subnet-
--associate-public-address --iam-instance-profile Name=phpdeveloperRole --user-data file://itmo444-env/install-webserver.sh --output table | grep InstanceId | sed "s/|//g" | tr -d ' ' | sed "s/InstanceId//g")
#display array contents
echo {instanceARR[@]}

#wait till instances are launched
aws ec2 wait instance-running --instance-ids ${instanceARR[@]}

#tell user that instances are running
echo "instances are running"
@
@

