#!/bin/bash
sudo apt-get update
# install java 8
sudo apt install openjdk-8-jre-headless -y
cd /opt

sudo wget https://download.sonatype.com/nexus/3/nexus-3.63.0-01-unix.tar.gz
tar -zxvf nexus-3.63.0-01-unix.tar.gz
sudo mv /opt/nexus-3.63.0-01 /opt/nexus

sudo adduseradd nexus
sudo visudo
#Add below line into it , save and exit
nexus ALL=(ALL) NOPASSWD: ALL

sudo chown -R nexus:nexus /opt/nexus
sudo chown -R nexus:nexus /opt/sonatype-work

sed -i 's/#run_as_user=""/run_as_user="nexus"/g' /opt/nexus/bin/nexus.rc
cat /opt/nexus/bin/nexus.rc

cat <<EOF >> /etc/systemd/system/nexus.service
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl start nexus
sudo systemctl enable nexus