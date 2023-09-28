#!/bin/bash

#To install the mongodb in the linux server

USERID=$(id -u)
LOGDIR=/tmp
SCRIPTNAME=$0
DATE=$(date +%F)
LOGFILE=$LOGDIR/$SCRIPTNAME-$DATE.log
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

# to find whether it is having root access or not

if [ $USERID -ne 0 ];
then
echo -e "$R Error:please install with Root Access $N"
exit 1
fi

VALIDATE() {
if [ $1 -ne 0 ];
then
echo -e "$2 is $R Failure $N"
exit 1
else
echo -e "$2 is $G Success $N"
fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copied to Mongo repo"

yum install mongodb-org -y &>> $LOGFILE
VALIDATE $? "Installing the MongoDB"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "Enabling the Service"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "Starting the Service"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "Editing the Config file"

systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarting the Service"
