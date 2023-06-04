#!/bin/bash

########################## Task 2 ###########################################
 #updating the packages
apt update -y

s3_bucket=upgrad-namrata
TarName=""

#check for apache is install
dpkg --get-selections | grep apache | grep -w "install"

NSTATUS=$?

if [ "$NSTATUS" != "0" ]; then
        sudo apt --assume-yes install apache2
        sync

fi

#Check for apache is enable and running
if systemctl status apache2 | grep -q 'disabled'; then
        systemctl enable apache2
        echo "Apache2 enabled now"
        systemctl start apache2

else
        if systemctl status apache2 | grep -q 'active (running)'; then
                echo "Apache server is running"
        else
                systemctl start apache2
                echo "Apache2 service started"
        fi
fi

#Creating Tar file in /tmp folder
if [ -d "/var/log/apache2/" ]; then

        cd /var/log/apache2/
        myname=Namrata
        timestamp=`date '+%d%m%Y-%H%M%S'`
        echo $timestamp
        TarName="/tmp/${myname}-httpd-logs-${timestamp}.tar"
        tar -zcvf $TarName *.log
fi

#checking forawscli is install or not
dpkg --get-selections | grep awscli | grep -w "install"

if [ $? != 0 ];then
  echo "updating aws package"
  apt-get update
  apt-get --assume-yes install awscli
fi

#upload local tar to s3 bucket
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

################# TASK 2 END ######################################################

FILENAME=/var/www/html/inventory.html

if [ ! -f $FILENAME ]; then

        touch $FILENAME
        echo \<table border=1 cellpadding=1 cellspacing=0 bordercolor=BLACK\> >> $FILENAME
        echo \<tr\> >> $FILENAME
        echo \<td\>"Log-Type"\<\/td\> >> $FILENAME
        echo \<td\>"Date-Created"\<\/td\> >> $FILENAME
        echo \<td\>"Type"\<\/td\> >> $FILENAME
        echo \<td\>"Size"\<\/td\> >> $FILENAME
        echo \<\/tr\> >> $FILENAME

        echo \<tr\> >> $FILENAME
        echo \<td\>$(echo $TarName | cut -d "-" -f 2,3)\<\/td\> >> $FILENAME
        echo \<td\>$(echo $TarName | cut -d "-" -f 4,5 | cut -d "." -f -1)\<\/td\> >> $FILENAME
        echo \<td\>$(echo $TarName | cut -d '.' -f 2)\<\/td\> >> $FILENAME
        echo \<td\>$(du -h "$TarName" | awk '{print $1}')\<\/td\> >> $FILENAME
        echo \<\/tr\> >> $FILENAME
        echo \<\/table\> >> $FILENAME

else

myFile=/var/www/html/inventory1.html

while read -a line; 
do

echo "$line"
  if [ `echo "$line" | grep -Fn /table` ]; then
        echo \<tr\> >> $myFile
        echo \<td\>$(echo $TarName | cut -d "-" -f 2,3)\<\/td\> >> $myFile
        echo \<td\>$(echo $TarName | cut -d "-" -f 4,5 | cut -d "." -f -1)\<\/td\> >> $myFile
        echo \<td\>$(echo $TarName | cut -d '.' -f 2)\<\/td\> >> $myFile
        echo \<td\>$(du -h "$TarName" | awk '{print $1}')\<\/td\> >> $myFile
        echo \<\/tr\> >> $FILENAME

      echo "$line" >> $myFile
      break
   else
       if [ `echo "$line" | grep -Fn \<table` ]; then
                echo \<table border=1 cellpadding=1 cellspacing=0 bordercolor=BLACK\> >> $myFile
       else
                echo "$line" >> $myFile
       fi
   fi

done < $FILENAME

sync

if [ -f $myFile ]; then
        rm $FILENAME
        cp $myFile $FILENAME
        sync
        rm $myFile
fi

fi

#Setting Cronjob
if [ -f "/etc/cron.d/automation" ];then
        echo "automation crontab already exist"

else
        touch /etc/cron.d/automation
        echo "0 0 * * * root /root/Automation_Project/automation.sh" > /etc/cron.d/automation

fi
###################Task 3 END################################

########ways to wrie in inventry.html but its not giving proper view in browser################

<<comm
#1
if [ ! -f $FILENAME ]; then

        touch $FILENAME
        printf "\tLog-Type\t\tDate-Created\t\t\tType\t\t\tSize" >> $FILENAME
fi

        printf "\n\t$(echo $TarName | cut -d "-" -f 2,3)" >> $FILENAME
        printf "\t\t$(echo $TarName | cut -d "-" -f 4,5 | cut -d "." -f -1)" >> $FILENAME
        printf "\t\t\t $(echo $TarName | cut -d '.' -f 2)" >> $FILENAME
        printf "\t\t\t$(du -h "$TarName" | awk '{print $1}')" >> $FILENAME

#2
if [ ! -f $FILENAME ]; then

        touch $FILENAME
        echo -e "\tLog-Type\t\tDate-Created\t\t\tType\t\t\tSize" >> $FILENAME
	echo -ne "\n\t$(echo $TarName | cut -d "-" -f 2,3)" >> $FILENAME
        echo -ne "\t\t$(echo $TarName | cut -d "-" -f 4,5 | cut -d "." -f -1)" >> $FILENAME
        echo -ne "\t\t\t $(echo $TarName | cut -d '.' -f 2)" >> $FILENAME
        echo -ne "\t\t\t$(du -h "$TarName" | awk '{print $1}')" >> $FILENAME
else

	echo -e "\n"
       	echo -ne "\n\t$(echo $TarName | cut -d "-" -f 2,3)" >> $FILENAME
        echo -ne "\t\t$(echo $TarName | cut -d "-" -f 4,5 | cut -d "." -f -1)" >> $FILENAME
  
echo -ne "\t\t\t $(echo $TarName | cut -d '.' -f 2)" >> $FILENAME
        echo -ne "\t\t\t$(du -h "$TarName" | awk '{print $1}')" >> $FILENAME
fi
comm


