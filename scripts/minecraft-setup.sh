#!/bin/bash

# Disclaimer: This shell script is intended for EC2 ARM Servers to be cheaper
#             Take that into consideration
# Original Script from: https://aws.amazon.com/blogs/gametech/setting-up-a-minecraft-java-server-on-amazon-ec2/

# Access the URL via command-line argument for specific Minecraft version
MINECRAFT_SERVER_URL=${version}

# Output the URL, or an error if not found
if [[ -z "$MINECRAFT_SERVER_URL" ]]; then
    echo "Version not found."
else
    echo "Download URL for Minecraft version: $MINECRAFT_SERVER_URL"
fi

# Downlaod Java and MC Server
sudo yum install -y java-21-amazon-corretto-headless

adduser minecraft

mkdir /opt/minecraft
mkdir /opt/minecraft/server
mkdir /opt/minecraft/server/logs

# Install MC Server
cd /opt/minecraft/server

wget $MINECRAFT_SERVER_URL

chown -R minecraft:minecraft /opt/minecraft/server

sudo chmod -R 775 /opt/minecraft/server

java -Xmx${system_memory}M -Xms${system_memory}M -jar server.jar nogui

sleep 50 # let's give some time for the server to start!

sed -i 's/false/true/p' eula.txt

# Add initial server configurations
cat <<EOF > server.properties
#Minecraft server properties
#Mon Jul 15 02:39:54 UTC 2024
accepts-transfers=false
allow-flight=false
allow-nether=true
broadcast-console-to-ops=true
broadcast-rcon-to-ops=true
bug-report-link=
difficulty=easy
enable-command-block=false
enable-jmx-monitoring=false
enable-query=true
enable-rcon=false
enable-status=true
enforce-secure-profile=true
enforce-whitelist=false
entity-broadcast-range-percentage=100
force-gamemode=false
function-permission-level=2
gamemode=survival
generate-structures=true
generator-settings={}
hardcore=false
hide-online-players=false
initial-disabled-packs=
initial-enabled-packs=vanilla
level-name=world
level-seed=
level-type=minecraft\:normal
log-ips=true
max-chained-neighbor-updates=1000000
max-players=20
max-tick-time=60000
max-world-size=29999984
motd=A Minecraft Server
network-compression-threshold=256
online-mode=true
op-permission-level=4
player-idle-timeout=0
prevent-proxy-connections=false
pvp=true
query.port=9200
rate-limit=0
rcon.password=
rcon.port=25575
region-file-compression=deflate
require-resource-pack=false
resource-pack=
resource-pack-id=
resource-pack-prompt=
resource-pack-sha1=
server-ip=
server-port=25565
simulation-distance=10
spawn-animals=true
spawn-monsters=true
spawn-npcs=true
spawn-protection=16
sync-chunk-writes=true
text-filtering-config=
use-native-transport=true
view-distance=10
white-list=false
EOF

touch start
printf '#!/bin/bash\njava -Xmx${system_memory}M -Xms${system_memory}M -jar server.jar nogui\n' >> start
chmod +x start
sleep 1
touch stop
printf '#!/bin/bash\nkill -9 $(ps -ef | pgrep -f "java")' >> stop
chmod +x stop
sleep 1

chown -R minecraft:minecraft /opt/minecraft/server/logs
chmod -R 775 /opt/minecraft/server/logs

# Create SystemD Script to run Minecraft server jar on reboot
cd /etc/systemd/system/
touch minecraft.service
cat <<EOF > minecraft.service
[Unit]
Description=Minecraft Server on start up
Wants=network-online.target

[Service]
User=minecraft
WorkingDirectory=/opt/minecraft/server
ExecStart=/opt/minecraft/server/start
StandardInput=null
StandardOutput=append:/opt/minecraft/server/logs/latest.log
StandardError=append:/opt/minecraft/server/logs/latest.log

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable minecraft.service
sudo systemctl start minecraft.service

# Install Node Exporter Agent to export server metrics
mkdir /opt/node_exporter
cd /opt/node_exporter

wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-arm64.tar.gz
tar xvfz node_exporter-1.8.1.linux-arm64.tar.gz

chown -R minecraft:minecraft /opt/node_exporter/node_exporter-1.8.1.linux-arm64

# Create systemd service file
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=minecraft
Group=minecraft
Type=simple
ExecStart=/opt/node_exporter/node_exporter-1.8.1.linux-arm64/node_exporter --collector.systemd

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable node_exporter.service
sudo systemctl start node_exporter.service

# Install and enable FTP
adduser ${ftp_user}
echo "${ftp_user}:${ftp_password}" | sudo chpasswd

sudo yum install -y vsftpd

echo "chroot_local_user=YES" >> /etc/vsftpd/vsftpd.conf
echo "allow_writeable_chroot=YES" >> /etc/vsftpd/vsftpd.conf
echo "pasv_enable=YES" >> /etc/vsftpd/vsftpd.conf
echo "pasv_min_port=1024" >> /etc/vsftpd/vsftpd.conf
echo "pasv_max_port=1048" >> /etc/vsftpd/vsftpd.conf
echo "write_enable=YES" >> /etc/vsftpd/vsftpd.conf
echo "local_umask=022" >> /etc/vsftpd/vsftpd.conf
echo "anon_world_readable_only=NO" >> /etc/vsftpd/vsftpd.conf
echo "anon_upload_enable=YES" >> /etc/vsftpd/vsftpd.conf
echo "anon_mkdir_write_enable=YES" >> /etc/vsftpd/vsftpd.conf
echo "anon_other_write_enable=YES" >> /etc/vsftpd/vsftpd.conf

sudo usermod -d /opt/minecraft/server ${ftp_user}

usermod -a -G minecraft ${ftp_user}

sudo chmod -R 775 /opt/minecraft/server

sudo systemctl enable vsftpd
sudo chkconfig --level 345 vsftpd on
sudo systemctl start vsftpd