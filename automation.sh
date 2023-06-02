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
