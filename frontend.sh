#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FLODER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FLODER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FLODER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

# check the user has root priveleges or not
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1 #give other than 0 upto 127
else
    echo "You are running with root access" | tee -a $LOG_FILE
fi

# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
     if [ $1 -eq 0 ]
    then
        echo -e "Installing $2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "Installing $2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}


dnf module disable nginx -y &>>$LOGS_FLODER
VALIDATE $? "Disabling Default Nginx"

dnf module enable nginx:1.24 -y &>>$LOGS_FLODER
VALIDATE $? "Enabling Nginx:1.24"

dnf install nginx -y &>>$LOGS_FLODER
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOGS_FLODER
systemctl start nginx 
VALIDATE $? "Starting Nginx" 

rm -rf /usr/share/nginx/html/* &>>$LOGS_FLODER
VALIDATE $? "Removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_FLODER
VALIDATE $? "Downloading frontend"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOGS_FLODER
VALIDATE $? "unzipping forntend"

rm -rf /etc/nginx/nginx.conf &>>$LOGS_FLODER
VALIDATE $? "Remove default nginx cong"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying nginx.conf"

systemctl restart nginx
VALIDATE $? "Restarting nginx"