#!/bin/bash
# Quick and easy Seedbox setup with FTP support for mobile devices
# Created by Marshall Ford - Released to LowEndTalk.com - Orginal commands from http://bit.ly/184MgKM
# 6/5/2013 v1

clear
# Do some sanity checking.
	if [ $(/usr/bin/id -u) != "0" ]
	then
		die 'Must be run by root user'
	fi

	if [ ! -f /etc/debian_version ]
	then
		die "Distribution is not supported"
	fi
echo -e "Seedbox Setup\n------------------------"
echo "Creating seedbox user..."
adduser seedbox
echo "Downloading and installing uTorrent..."
cd /home/seedbox
mkdir torrent-files
mkdir downloads
cd /opt/
wget http://download.utorrent.com/linux/utorrent-server-3.0-ubuntu-10.10-27079.tar.gz
tar -zxvf utorrent-server-3.0-ubuntu-10.10-27079.tar.gz
mv utorrent-server-v3_0 utorrent
cd utorrent
echo "Creating init script..."
chmod +x utserver
touch /etc/init.d/utorrent
cat > /etc/init.d/utorrent <<EOF

#!/bin/bash
### BEGIN INIT INFO
# Provides:          utserver
# Required-Start:    
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# X-Interactive:     true
# Short-Description: Start/stop utserver
### END INIT INFO
 
case "$1" in
  start)
        echo Starting utorrent server
        cd /opt/utorrent
        ./utserver &
        ;;
  stop)
        echo Stopping utorrent server
        killall utserver
        ;;
    *)
        echo Usage: start  stop
        exit 1
        ;;
    esac


exit 0

EOF
chmod 755 /etc/init.d/utorrent
update-rc.d -f utorrent defaults
echo "Congrats! Your Seedbox installation is complete."
echo "
URL: http://yourip:8080/gui
USERNAME: admin
PASSWORD: (empty)
"
echo "Would you like to install vsftpd (FTP) for mobile access? (y/n)"
read answer
if [ "$answer" = "y" ]; then
    apt-get install vsftpd
    echo "Now modifying the vsftpd config, please adjust the following..."
    echo "
    anonymous_enable=NO
    local_enable=YES
    write_enable=YES
    chroot_local_user=YES
    "
    nano /etc/vsftpd.conf
    chown root:root /home/seedbox
    chown seedbox:seedbox /home/seedbox/downloads
    chown seedbox:seedbox /home/seedbox/torrent-files
    service vsftpd restart
    echo "FTP setup is complete, to login use the following..."
    echo "
    IP/HOST: your-ip
    USERNAME: seedbox
    PASSWORD: seedbox's password you set earlier
    PORT: 21
    "
    echo "And again, your Seedbox web Login info..."
	echo "
	URL: http://yourip:8080/gui
	USERNAME: admin
	PASSWORD: (empty)
	"
fi
echo "Remember to change the uTorrent download folder to /home/seedbox/downloads and the torrent folder to /home/seedbox/torrent-files"
echo "Please reboot to start your Seedbox"
echo "Reboot Now? (y/n)"
read reboot
if [ "$reboot" = "y" ]; then
	reboot
fi