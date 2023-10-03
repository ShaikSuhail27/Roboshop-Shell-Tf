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

## Installing the Cart Microservice 

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE
VALIDATE $? "Installing the Node environment"

yum install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing the Node JS"

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

#curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "Downloading the Cart Package"

cd /app &>> $LOGFILE
VALIDATE $? "Moving to the app directory"

unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "Unzipping the package into the app directory"

npm install &>> $LOGFILE
VALIDATE $? "Installing the Node JS dependencies"

cp /home/centos/Roboshop-Shell-Tf/Cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "Configuring the service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Reloading the Service"

systemctl enable cart &>> $LOGFILE
VALIDATE $? "Enabling the Service"

systemctl start cart &>> $LOGFILE
VALIDATE $? "Starting the Service"




