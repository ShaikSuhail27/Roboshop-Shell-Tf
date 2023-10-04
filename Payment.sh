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

## Installing the Payment Microservice 

yum install python36 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "Installing the Python"

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

#curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "Downloading the Payment Package"

cd /app &>> $LOGFILE
VALIDATE $? "Moving to the app directory"

unzip -o /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "Unzipping the package into the app directory"

pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "Installing the Python dependencies"

cp /home/centos/Roboshop-Shell-Tf/Payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "Configuring the service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Reloading the Service"

systemctl enable payment &>> $LOGFILE
VALIDATE $? "Enabling the Service"

systemctl start payment &>> $LOGFILE
VALIDATE $? "Starting the Service"




