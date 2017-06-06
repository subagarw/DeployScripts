#!/bin/bash
#!/usr/local/bin/expect -f

wget -O $ARTIFACT_PATH$ARTIFACT_NAME $ARTIFACT_URL
echo "download success"
chmod 777 $ARTIFACT_PATH$ARTIFACT_NAME


# ssh -o 'StrictHostKeyChecking no' $USER@$PUBLIC_IP
echo $USER@$PUBLIC_IP
if [ $CONFIGURE ];
then
echo "true"
ssh -i $KEY_PATH$KEY_NAME $USER@$PUBLIC_IP << EOF
sudo apt-get update
sudo mkdir testdeploy
cd testdeploy
sudo apt-add-repository ppa:webupd8team/java
sudo apt-get update
yes | sudo apt-get install oracle-java8-installer
sudo wget http://mirror.fibergrid.in/apache/tomcat/tomcat-8/v8.5.15/bin/apache-tomcat-8.5.15.tar.gz
sudo tar -xzvf apache-tomcat-8.5.15.tar.gz
sudo chmod 777 apache-tomcat-8.5.15/webapps
logout
EOF
sleep 30
scp -i $KEY_PATH$KEY_NAME $ARTIFACT_PATH$ARTIFACT_NAME $USER@$PUBLIC_IP:testdeploy/apache-tomcat-8.5.15/webapps
sleep 30
else
echo "false"
scp -i $KEY_PATH$KEY_NAME $ARTIFACT_PATH$ARTIFACT_NAME $USER@$PUBLIC_IP:apache-tomcat-8.5.15/webapps
sleep 30
fi
ssh -i $KEY_PATH$KEY_NAME $USER@$PUBLIC_IP << EOF
sudo testdeploy/apache-tomcat-8.5.15/bin/startup.sh
logout
EOF
