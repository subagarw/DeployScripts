#!/bin/bash

wget -O $ARTIFACT_PATH$ARTIFACT_NAME $ARTIFACT_URL
echo "download success"

# ssh -o 'StrictHostKeyChecking no' $USER@$PUBLIC_IP
echo $USER@$PUBLIC_IP
if [ $CONFIGURE ];
then
        ssh -i $KEY_PATH$KEY_NAME $USER@$PUBLIC_IP << EOF
        sudo apt-get update
        sudo mkdir testdeploy
        cd testdeploy
        sudo apt-get install java-1.8.0 -y
        sudo apt-get install java-1.8.0-openjdk-devel -y
        sudo apt-get remove java-1.7.0-openjdk -y
        sudo wget http://mirrors.koehn.com/apache/tomcat/tomcat-8/v8.5.8/bin/apache-tomcat-8.5.8.tar.gz
        sudo tar -xzvf apache-tomcat-8.5.8.tar.gz
        sudo chmod 777 apache-tomcat-8.5.8/webapps
        sleep 30
        logout
        EOF
    sleep 30

        scp -i $KEY_PATH$KEY_NAME $ARTIFACT_PATH$ARTIFACT_NAME $USER@$PUBLIC_IP:apache-tomcat-8.5.8/webapps

        sleep 30
else

        scp -i $KEY_PATH$KEY_NAME $ARTIFACT_PATH$ARTIFACT_NAME $USER@$PUBLIC_IP:apache-tomcat-8.5.8/webapps
        sleep 30
fi


ssh -i $KEY_PATH$KEY_NAME $USER@$PUBLIC_IP << EOF
sudo  apache-tomcat-8.5.8/bin/startup.sh
logout
EOF
