#!/bin/sh

# Installing dependencies.
echo 'Updating packages and installing dependencies'
apt-get update
apt-get install curl screen supervisor netcat-traditional -y
service supervisor restart

# Add a new user for all Minecraft stuff.
echo 'Setting up new user and area for MCServer'
password=$(head -c 9 < /dev/urandom | base64)
useradd -m -p $password minecraft
usermod -d /minecraft -m minecraft

# Download the intial version of MCServer.
echo 'Installing MCServer'
su minecraft -c 'cd /tmp; curl -s https://raw.githubusercontent.com/mc-server/MCServer/master/easyinstall.sh | sh'
su minecraft -c 'mv /tmp/MCServer/* /minecraft'
rmdir /tmp/MCServer
cd /minecraft
su minecraft -c 'echo stop | ./MCServer'
su minecraft -c "sed -i -e 's/; \[User:admin\]/[User:admin]/' -e 's/; Password=admin/Password=$password/' webadmin.ini"

# Setting up the supervisor.
cat > /minecraft/startmcs.sh <<EOF
#!/bin/sh

cd /minecraft
./MCServer
EOF
chown minecraft /minecraft/startmcs.sh
su minecraft -c 'chmod +x /minecraft/startmcs.sh'

cat > /etc/supervisor/conf.d/mcserver.conf <<EOF
[program:mcserver]
command=/minecraft/startmcs.sh
user=minecraft
autostart=true
autorestart=true
stderr_logfile=/var/log/mcserver.log
stdout_logfile=/var/log/mcserver.log
EOF
supervisorctl reread
supervisorctl update

# Create temporary webpage.
externip=$(dig +short myip.opendns.com @resolver1.opendns.com)
cd /tmp/mcserver-ocean/
cat >info.html <<EOF
<html>
<head><title>MCServer Information</title></head>
<body>
<h1>MCServer Information</h1>
<p>
You can log in to the webadmin at <a target="_blank" href="http://$externip:8080">http://$externip:8080</a> with username admin and password $password. You can also log in to the server via SSH with username minecraft and password $password although it is recommended you set up SSH keys.
</p>
<p><b>
This page will self-destruct when you leave it, so please note down this information!
</b></p>
</body>
</html>
EOF

nohup nc.traditional -e 'webscript.sh' -l -p 80 &
