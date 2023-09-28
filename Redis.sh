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

## Installing the Redis Server

yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
VALIDATE $? "Configuring the REPO file"

yum module enable redis:remi-6.2 -y  &>> $LOGFILE
VALIDATE $? "Enabling the 6.2 Version"

yum install redis -y  &>> $LOGFILE
VALIDATE $? "Installing the REDIS"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf &>> $LOGFILE
VALIDATE $? "Modifying the port in the config file"

systemctl enable redis  &>> $LOGFILE
VALIDATE $? "Enabling the Service"

systemctl start redis  &>> $LOGFILE
VALIDATE $? "Starting the Service"

