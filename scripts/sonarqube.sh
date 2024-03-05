#!/bin/bash
sudo apt update -y
sudo apt install openjdk-17-jdk -y
# Install Postgresql
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update -y
sudo apt-get install postgresql-14 -y

systemctl start postgresql
systemctl enable postgresql
systemctl status postgresql

passwd postgres
su - postgres
createuser sonar
psql

ALTER USER sonar WITH ENCRYPTED PASSWORD 'sonar';
CREATE DATABASE sonarqube OWNER sonar;
GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar;
# Go to root user
systemctl restart postgresql
systemctl status postgresql

sysctl vm.max_map_count
sysctl fs.file-max
ulimit -n
ulimit -u

sysctl -w vm.max_map_count=524288
sysctl -w fs.file-max=131072
ulimit -n 131072
ulimit -u 8192

cat <<EOF >> /etc/security/limits.conf
# Set Config Sonar
sonarqube   -   nofile   131072
sonarqube   -   nproc    8192
EOF

# Install Sonarqube
cd /opt
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.4.87374.zip
sudo apt install unzip -y
unzip sonarqube-9.9.4.87374.zip
mv /opt/sonarqube-9.9.4.87374 /opt/sonarqube

vi /opt/sonarqube/conf/sonar.properties

cat <<EOF >> /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target
	
[Service]
Type=forking
User=sonarqube
Group=sonarqube
PermissionsStartOnly=true
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start 
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
StandardOutput=syslog
LimitNOFILE=65536
LimitNPROC=4096
TimeoutStartSec=5
Restart=always
	
[Install]
WantedBy=multi-user.target
EOF

useradd -d /opt/sonarqube sonarqube
chown -R sonarqube:sonarqube /opt/sonarqube