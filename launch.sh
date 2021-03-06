#! /bin/bash
./cleanup.sh

#declare an array in bash
declare -a instanceARR
mapfile -t instanceARR < <(aws ec2 run-instances --image-id ami-d05e75b8 --count $1 --instance-type t2.micro --key-name $3 --security-group-ids sg-5bba5c3d --subnet-id subnet-b92c7692 --associate-public-ip-address --iam-instance-profile Name=phpdeveloperRole --user-data file://install-webserver.sh --output table | grep InstanceId | sed "s/|//g" | tr -d ' ' | sed "s/InstanceId//g")
#display array contents
echo ${instanceARR[@]}

#wait till instances are launched
aws ec2 wait instance-running --instance-ids ${instanceARR[@]}
#tell user that instances are running
echo "INSTANCES ARE RUNNING"


#create load balancer
aws elb create-load-balancer --load-balancer-name $2 --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80 --subnets subnet-b92c7692 --security-groups sg-5bba5c3d --output=text
echo $2
echo -e "\nELB has loaded, waiting 25 seconds"
echo -e "\n"
for i in {0..25};do echo -ne '.';sleep 1;done
echo -e "\n"

#attach/register lb to instances
aws elb register-instances-with-load-balancer --load-balancer-name $2 --instances ${instanceARR[@]}

#health check policy based on given parameters
aws elb configure-health-check --load-balancer-name $2 --health-check Target=HTTP:80/index.html,Interval=30,UnhealthyThreshold=2,HealthyThreshold=2,Timeout=3

#create launch config to launch instances
aws autoscaling create-launch-configuration --launch-configuration-name balrifai-launch-config --image-id ami-d05e75b8 --key-name $3 --security-groups sg-5bba5c3d --instance-type t2.micro --user-data file://install-webserver.sh --iam-instance-profile phpdeveloperRole

#create autoscaling group
aws autoscaling create-auto-scaling-group --auto-scaling-group-name balrifai-scaling --launch-configuration-name balrifai-launch-config --load-balancer-names $2 --health-check-type ELB --min-size 3 --max-size 6 --desired-capacity 3 --default-cooldown 600 --health-check-grace-period 120 --vpc-zone-identifier subnet-b92c7692

#create cloud watch metrics
aws cloudwatch put-metric-alarm --alarm-name AddCapacity --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 30 --comparison-operator GreaterThanOrEqualToThreshold --dimensions "Name=AutoScalingGroupName,Value=balrifai-scaling" --evaluation-periods 2 --unit Percent
aws cloudwatch put-metric-alarm --alarm-name RemoveCapacity --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 10 --comparison-operator LessThanOrEqualToThreshold --dimensions "Name=AutoScalingGroupName,Value=balrifai-scaling" --evaluation-periods 2 --unit Percent

#create aws rds subnet &  instance
aws rds create-db-subnet-group --db-subnet-group-name mp1-dbsubnet --db-subnet-group-description "ITMO444 MP1 Subnet Group" --subnet-ids subnet-b92c7692 subnet-128b9865
aws rds create-db-instance --db-name balrifai --db-instance-identifier itmo444-mp1 --db-instance-class db.t2.micro --engine MySQL --master-username balrifai --master-user-password ilovebunnies --allocated-storage 10 --vpc-security-group-ids sg-5bba5c3d --db-subnet-group-name mp1-dbsubnet --publicly-accessible

aws rds wait db-instance-available --db-instance-identifier itmo444-mp1 

