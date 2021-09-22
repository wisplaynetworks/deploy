echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                                                       +"
echo "+    CREANDO VARIABLES      "
echo "+                                                                                     +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
ppp1=$(/sbin/ip route | awk '/default/ { print $3 }')
ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo "Listo..."
# Installing pptpd
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                                                       +"
echo "+    INSTALANDO PPTPD     "
echo "+                                                                                     +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
sudo apt-get install pptpd -y
echo "Listo..."
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                                                       +"
echo "+    ACTUALIZANDO PAQUETES   "
echo "+                                                                                     +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
sudo apt update -y
echo "Listo..."
# edit DNS
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                                                       +"
echo "+    Configurando DNS de Google   "
echo "+                                                                                     +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
sed -i 's/#ms-dns 8.8.8.8/ms-dns 8.8.8.8/g' /etc/ppp/pptpd-options
sed -i 's/#ms-dns 8.8.4.4/ms-dns 8.8.4.4/g' /etc/ppp/pptpd-options
echo "Listo..."
# Edit PPTP Configuration
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                                                       +"
echo "+    Editando la configuracion del PPTP  "
echo "+                                                                                     +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
remote="$ppp1"
remote+="01-254"
sudo echo "localip $ppp1" >> /etc/pptpd.conf
sudo echo "remoteip $remote" >> /etc/pptpd.conf
echo "Listo..."
# Enabling IP forwarding in PPTP server
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                                                       +"
echo "+    Habilitando el forwarding en el servidor PPTP "
echo "+                                                                                     +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sudo sysctl -p
if [ -z "$wan" ]
	then
		sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE && iptables-save
		sudo iptables --table nat --append POSTROUTING --out-interface ppp0 -j MASQUERADE
        iptables -A INPUT -p 47 -j ACCEPT
        iptables -A OUTPUT -p 47 -j ACCEPT
		$("sudo iptables -I INPUT -s $ip/23 -i ppp0 -j ACCEPT")
		sudo iptables --append FORWARD --in-interface wlan0 -j ACCEPT
	else
		sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE && iptables-save
		sudo iptables --table nat --append POSTROUTING --out-interface ppp0 -j MASQUERADE
        iptables -A INPUT -p 47 -j ACCEPT
        iptables -A OUTPUT -p 47 -j ACCEPT
		$("sudo iptables -I INPUT -s $ip/23 -i ppp0 -j ACCEPT")
		sudo iptables --append FORWARD --in-interface eth0 -j ACCEPT
fi
echo "Listo..."
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                                                       +"
echo "+    IP del servidor y configuracion del VPN "
echo "+                                                                                     +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
cat <<EOT > ip.log
IP Servidor: $ip
localip: $ppp1
remoteip: $remote
EOT
echo "Listo..."
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                                                       +"
echo "+    Habilitando VPN pptp"
echo "+                                                                                     +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
systemctl enable pptpd
echo "Listo..."
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                                                       +"
echo "+    Iniciando VPN pptp  "
echo "+                                                                                     +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
systemctl start pptpd
echo "Listo..."