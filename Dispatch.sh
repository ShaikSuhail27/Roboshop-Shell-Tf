#!/bin/bash

USERID=$(id -u)
LOGDIR=/tmp
SCRIPTNAME=$0
DATE=$(date +%F-%H:%M:%S)
LOGFILE=$LOGDIR/$SCRIPTNAME-$DATE.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USER="roboshop"
DIR_NAME="/app"

# Function for Success and failure
VALIDATE() {
if [ $1 -ne 0 ]
then
echo -e "$2 is $R Failure $N"
exit 1
else
echo -e "$2 is $G Success $N"
fi
}

# To find whether it is root access or not
if [ $USERID -ne 0 ];
then
echo -e "$R ERROR: Please install with root access $N"
exit 1
fi

## Installing the Dispatch Microservice 

yum install golang -y &>> $LOGFILE
VALIDATE $? "Installing the GOlang"

 id $USER > /dev/null 2>&1
 if [ $? -ne 0 ];
 then
useradd roboshop &>> $LOGFILE 
#VALIDATE $? "Adding the user"
else
echo -e "$Y $USER user already exists $N" &>> $LOGFILE 
fi
echo -e "$Y Adding the user $N"

if [ -d "$DIR_NAME" ];
then
echo -e "$Y Directory already exists $N" &>> $LOGFILE 
else
mkdir /app &>> $LOGFILE
#VALIDATE $? " Creating the App directory"
fi
echo -e "$Y Creating the App directory $N"

#curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> $LOGFILE
curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch.zip &>> $LOGFILE
VALIDATE $? "Downloading the dispatch Package"

cd /app &>> $LOGFILE
VALIDATE $? "Moving to the app directory"

unzip -o /tmp/dispatch.zip &>> $LOGFILE
VALIDATE $? "Unzipping the package into the app directory"

go mod init dispatch &>> $LOGFILE
VALIDATE $? "Installing the Golang dependencies"

go get &>> $LOGFILE
VALIDATE $? "Installing the Golang dependencies"

go build &>> $LOGFILE
VALIDATE $? "Installing the Golang dependencies"

cp /home/centos/Roboshop-Shell/Dispatch.service /etc/systemd/system/dispatch.service &>> $LOGFILE
VALIDATE $? "Configuring the service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Reloading the Service"

systemctl enable dispatch &>> $LOGFILE
VALIDATE $? "Enabling the Service"

systemctl start dispatch &>> $LOGFILE
VALIDATE $? "Starting the Service"




