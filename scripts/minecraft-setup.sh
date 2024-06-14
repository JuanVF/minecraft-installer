#!/bin/bash

# Disclaimer: This shell script is intended for EC2 ARM Servers to be cheaper
#             Take that into consideration
# Original Script from: https://aws.amazon.com/blogs/gametech/setting-up-a-minecraft-java-server-on-amazon-ec2/

# Setup Minecraft Server Version Downloads URLs
declare -A minecraft_servers_urls

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

cd /opt/minecraft/server

wget $MINECRAFT_SERVER_URL

# Install MC Server
chown -R minecraft:minecraft /opt/minecraft/

java -Xmx1300M -Xms1300M -jar server.jar nogui

sleep 50 # let's give some time for the server to start!

sed -i 's/false/true/p' eula.txt
touch start
printf '#!/bin/bash\njava -Xmx1300M -Xms1300M -jar server.jar nogui\n' >> start
chmod +x start
sleep 1
touch stop
printf '#!/bin/bash\nkill -9 $(ps -ef | pgrep -f "java")' >> stop
chmod +x stop
sleep 1

# Create SystemD Script to run Minecraft server jar on reboot
cd /etc/systemd/system/
touch minecraft.service
printf '[Unit]\nDescription=Minecraft Server on start up\nWants=network-online.target\n[Service]\nUser=minecraft\nWorkingDirectory=/opt/minecraft/server\nExecStart=/opt/minecraft/server/start\nStandardInput=null\n[Install]\nWantedBy=multi-user.target' >> minecraft.service
sudo systemctl daemon-reload
sudo systemctl enable minecraft.service
sudo systemctl start minecraft.service