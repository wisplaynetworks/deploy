###dig +short myip.opendns.com @resolver1.opendns.com

wget https://git.io/vpn -O openvpn-install.sh
chmod +x openvpn-install.sh
nano openvpn-install.sh




sudo systemctl stop openvpn-server@server.service # <--- stop server
sudo systemctl start openvpn-server@server.service # <--- start server
sudo systemctl restart openvpn-server@server.service # <--- restart server
sudo systemctl status openvpn-server@server.service # <--- get server status