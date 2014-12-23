cd /tmp
curl -s https://raw.githubusercontent.com/mc-server/MCServer/master/easyinstall.sh | sh
rm /minecraft/MCServer
cp /tmp/MCServer/MCServer /minecraft/MCServer
rm -rf /tmp/MCServer
