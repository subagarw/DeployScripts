#!/bin/bash

if [ $ProvisioningPermit ];
then
        $INSTANCE_NAME=$INSTANCE_NAME$BUILD_NUMBER
        echo $BUILD_NUMBER > lastserver
        echo "Provisioning new server"
        echo "creating security group $SECURITY_GROUP opening port 22, 80, 8080"
        aws ec2 create-security-group --group-name $GROUP_NAME --description "Security group from jenkins"
        aws ec2 authorize-security-group-ingress --group-name $GROUP_NAME --protocol tcp --port 22 --cidr 0.0.0.0/0
        aws ec2 authorize-security-group-ingress --group-name $GROUP_NAME --protocol tcp --port 80 --cidr 0.0.0.0/0
        aws ec2 authorize-security-group-ingress --group-name $GROUP_NAME --protocol tcp --port 8080 --cidr 0.0.0.0/0
        echo "getting security group Id for $SECURITY_GROUP"
        SGID=$(aws ec2 describe-security-groups --group-names $GROUP_NAME --query SecurityGroups[0].GroupId | sed 's/"//g')
        echo "creating new key pair"
        aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text > $KEY_NAME.pem
        echo "waiting for the key to get generated"
        sleep 10
        chmod 400 $KEY_NAME.pem
        echo "creating Instance"
        INSTANCE_ID=$(aws ec2 run-instances --image-id $IMAGE_ID --security-group-ids $SGID --count 1 --instance-type $INSTANCE_TYPE --key-name $KEY_NAME --query 'Instances[0].InstanceId' | sed 's/"//g')
        echo $INSTANCE_ID > Build$BUILD_NUMBER/instanceid.txt
        aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=$INSTANCE_NAME
else
        LAST_SERVER=$(cat lastserver)
        $INSTANCE_NAME=$INSTANCE_NAME$LAST_SERVER
        echo "Using the last spun up server"
        INSTANCE_ID=$(cat Build$LAST_SERVER/instanceid.txt)
fi

echo "getting public IP"
Publicip=$(aws ec2 describe-instances --instance-ids ${Instanceid} --query 'Reservations[0].Instances[0].PublicIpAddress' | sed 's/"//g')