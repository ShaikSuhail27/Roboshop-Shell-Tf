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

## Installing the Nginx web server

yum install nginx -y &>> $LOGFILE
VALIDATE $? "Installing the Nginx Server"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "Enabling the Nginx Service"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "Starting the Nginx Service"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "Removing the HTML Content"

#curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>> $LOGFILE
VALIDATE $? "downloading the web package"

cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "Moving to the HTML directory"

#unzip /tmp/web.zip &>> $LOGFILE
unzip /tmp/frontend.zip &>> $LOGFILE
VALIDATE $? "Extracting the WEB zip file"

cp /home/centos/Roboshop-Shell-Tf/Roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATE $? "configuring the roboshop config file and using Reverse proxy configuration"

systemctl restart nginx &>> $LOGFILE
VALIDATE $? "Restarting the Nginx Service"

