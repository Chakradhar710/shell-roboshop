#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-00c30ba058098ea3b"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "fronted")
ZONE_ID="Z023666325XPYAQAW6FZN"
DOMAIN_NAME="chakri.icu"

for instance in ${INSTANCES[@]}
do
   INSTADNCES_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.micro --security-group-ids sg-00c30ba058098ea3b --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    if [ $instance != "frontend" ]
    then
       IP=$(aws ec2 describe-instances --instance-ids $INSTADNCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTADNCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    fi    
    echo "$instance IP address: $IP"
done