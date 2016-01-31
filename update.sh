cd /tmp
curl -s https://raw.githubusercontent.com/cuberite/cuberite/master/easyinstall.sh | sh
rm /minecraft/Cuberite
cp /tmp/Server/Cuberite /minecraft/Cuberite
rm -rf /tmp/Server
