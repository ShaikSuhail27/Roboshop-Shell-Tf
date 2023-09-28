#!/bin/bash

SERVER_NAMES=$@
INSTANCE_TYPE=" "
IMAGE_ID=ami-03265a0778a880afb
SECURITY_GID=sg-05fe3b7791764948d
DOMAIN_NAME=suhaildevops.online

for i in $@
do
# if  it is Mongodb or Mysql then need to create t3.medium or else t2.micro
if [[ $i == "MongoDB" || $i == "MYSQL" ]]
then
INSTANCE_TYPE="t3.medium"
else
INSTANCE_TYPE="t2.micro"
fi
echo "Creating the $i Instance"
IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID  --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
echo "Created the $i Instance" :$IP_ADDRESS

aws route53 change-resource-record-sets --hosted-zone-id Z00775633KJ6HCU16HBU4 --change-batch '{
            "Comment": "CREATE",
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                                    "Name": "'$i.$DOMAIN_NAME'",
                                    "Type": "A",
                                    "TTL": 300,
                                 "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
}}]
}'
done