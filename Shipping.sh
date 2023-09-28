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

## Installing the Shipping Microservice 

yum install maven -y &>> $LOGFILE
VALIDATE $? "Installing the Java environment"

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

#curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "Downloading the Shipping package"

cd /app &>> $LOGFILE
VALIDATE $? "Moving to APP directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "Extracting the Shipping ZIP file"

mvn clean package &>> $LOGFILE
VALIDATE $? "Installing the dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "Renaming the File"

cp /home/centos/Roboshop-Shell/Shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "Configuring the Shipping service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Reloading the Service"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "Enabling the Service"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "Starting the Service"

yum install mysql -y &>> $LOGFILE
VALIDATE $? "Installing the MY SQL Client"

mysql -h  mysql.suhaildevops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "Loading the Schema"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "Retarting the Service"
