#! /bin/bash

./cleanup.sh

#declare an array in bash
declare -a instanceARR
mapfile -t instanceARR < < (aws ec2 run-instances --image-id ami-d05e75b8 --count $1 --instance-type t2.micro --key-name itmo444-virtualbox --security-group-ids sg-5bba5c3d --subnet-id subnet-b92c7692
--associate-public-address --iam-instance-profile Name=phpdeveloperRole --user-data file://itmo444-env/install-webserver.sh --output table | grep InstanceId | sed "s/|//g" | tr -d ' ' | sed "s/InstanceId//g")
#display array contents
echo {instanceARR[@]}

#wait till instances are launched
aws ec2 wait instance-running --instance-ids ${instanceARR[@]}

#tell user that instances are running
echo "instances are running"
@
@

#create load balancer array
ELBURL=('aws elb create-load-balancer --load-balancer-name $2 --listeners Protocol=HTTP,LoadBalancerPort=80 --subnets subnet-b92c7692 --security-groups sg-5bba5c3d --output=text');
echo $ELBURL

echo -e "\nELB has loaded, waiting 25 seconds"
echo -e "\n"
for i in {0..25};do echo -ne '.';sleep 1;done
echo -e "\n"

#attach/register lb to instances
aws elb register-instances-with-load-balancer --load-balancer-name $2 --instances ${instanceARR[@]}

#health check policy based on given parameters
aws elb configure-health-check --load-balancer-name $2 --health-check Target=HTTP:80/index.html,Interval=30,UnhealthyThreshold=2,HealthyThreshold=2,Timeout=3
 
