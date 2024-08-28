LOG_FOLDER="/var/log/shell-script"
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

USAGE(){
    echo -e "$R USAGE:: $N sudo sh 16.redirectors.sh package1 package2 ...."
    exit 1
}

echo "Script started executing at: $(date)" | tee -a $LOG_FILE
   
CHECK_ROOT

dnf install mysql-server -y
VALIDATE $? "Installing MySQL"


systemctl enable mysqld
VALIDATE $? "Enabled MySQL"

systemctl start mysqld
VALIDATE $? "Started MySQL"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Setting Up Root Password"
