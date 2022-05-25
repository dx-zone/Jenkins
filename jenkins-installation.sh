#! /usr/bin/env bash
# Author: Daniel Cruz
# Description: Script to install Jenkins with Nginx to proxy connections from port 8080 to port 80 on CentOS8
# 

# Update the system and install misc packages
yum update -y
yum install wget net-tools dnf tcpdump -y

# Enable and configure firewalld rules
systemctl enable firewalld
systemctl restart firewalld
YOURPORT=8080
PERM="--permanent"
SERV="$PERM --service=jenkins"
firewall-cmd $PERM --new-service=jenkins
firewall-cmd $SERV --set-short="Jenkins ports"
firewall-cmd $SERV --set-description="Jenkins port exceptions"
firewall-cmd $SERV --add-port=$YOURPORT/tcp
firewall-cmd $PERM --add-service=jenkins
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --reload
systemctl restart firewalld

# Setup Jenkins repo
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
sleep 5
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key

# Install Java
yum install fontconfig java-11-openjdk -y

# Install Jenkins
yum install jenkins -y

# Enable and start Jenkins service
systemctl enable jenkins.service
systemctl start jenkins.service

# SELINUX
yum install policyoreutils-devl settroubleshoot-server -y
semanage port -a -t http_port_t -p tcp 8080

# Installing and setting nginx as proxy to redirect traffic from port 80 to 8080 (Jenkins's default port)
yum install nginx -y
if [[ ! -f /etc/nginx/nginx.conf.orig ]]
  then
  cp -a /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
fi

# 
grep -v '#' /etc/nginx/nginx.conf.orig > /etc/nginx/nginx.conf
sed -i 's/location \/ {/location \/ {\nproxy_pass http:\/\/127.0.0.1:8080;/g' /etc/nginx/nginx.conf
systemctl enable nginx
systemctl restart nginx
setsebool -P httpd_can_network_connect 1&
setsebool -P httpd_can_network_relay 1&