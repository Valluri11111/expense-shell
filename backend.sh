LOG_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOG_FOLDER

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Please run the script with root privilages $N" | tee -a $LOG_FILE
        exit 1
    fi
}
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is... $R Failed $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is... $G Success $N" | tee -a $LOG_FILE
   fi
   }

echo "Script started executing at: $(date)" | tee -a $LOG_FILE
   
CHECK_ROOT

dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disable default NodeJS"

dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "Enable NodeJS:20"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "Install NodeJS"

id expense &>> $LOG_FILE
if [ $? -ne 0 ]
then
    echo -e "expense user not exists...$G Create it $N"
    useradd expense &>> $LOG_FILE
    VALIDATE $? "Creating expense user"
else
    echo -e "expense user already exists...$Y Skipping $N"
fi

mkdir -p /app
VALIDATE $? "Creating App Folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> $LOG_FILE
VALIDATE $? "Downloading Backend Application code"

cd /app
rm -rf /app/* #remove the existing code
unzip /tmp/backend.zip &>> $LOG_FILE
VALIDATE $? "Extracting Backend Application code"