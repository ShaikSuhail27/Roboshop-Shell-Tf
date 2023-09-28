#!/bin/bash

#To install the RabbitMQin the linux server

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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "Configuring YUM repository"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "Configuring Rabbit MQ"

yum install rabbitmq-server -y &>> $LOGFILE
VALIDATE $? "Installing Rabbit MQ"

systemctl enable rabbitmq-server &>> $LOGFILE
VALIDATE $? "Enabling the service"

systemctl start rabbitmq-server &>> $LOGFILE
VALIDATE $? "Starting the service"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
VALIDATE $? "Adding the user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
VALIDATE $? "Setting the permissions"