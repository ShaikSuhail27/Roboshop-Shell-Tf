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

# Installing the My sql Server

yum module disable mysql -y  &>> $LOGFILE
VALIDATE $? "Disabling the module for installing another version"

cp /home/centos//Roboshop-Shell/Mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE
VALIDATE $? "Configuring the My sql repo file"

yum install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "Installing My sql community server"

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "Enabling the service"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "Starting the service"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? "Setting the Root password"

mysql -uroot -pRoboShop@1 &>> $LOGFILE
VALIDATE $? "Testing the Root password"

