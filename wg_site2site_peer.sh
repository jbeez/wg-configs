#!/bin/sh
#Rev 1.1
#Oct 4, 2022
#Tested on pfsense 2.6.0-RELEASE
#
#jtbright
#user defined variables, edit these before running the script.
#refer to the wireguard documentation for additional information on these values
###############################################################
wg="/usr/local/bin/wg"
touch="/usr/bin/touch"
chmod="/bin/chmod"
cat="/bin/cat"
###############################################################

read -p "Enter the PFSense Public Key: " pfsensepubkey
read -p "Enter the last octet of the PTP client side static IP(odd number): " lastquad
read -p "Enter the PFSense tunnel port(51820-518??): " remport

pfquad=$(($lastquad-1))
address="10.150.0.$lastquad"

privkey="$($wg genkey)"
pubkey="$(echo $privkey | $wg pubkey)"
psk="$($wg genpsk)"

echo "For the firewall administrator."
echo "Use the following values to add the new peer in the PfSense WG configuration page."
echo "###############################################################"
echo "Public Key: "$pubkey
echo "Preshared Key: "$psk
echo "Allowed IPs: "$address"/31 & Edgerouter's LAN Subnet"
echo "###############################################################"
echo
echo "###############################################################"
echo "For edgerouter configuration"
echo "###############################################################"
echo
echo "sudo su -"
echo "echo "$privkey" >/config/auth/wg.key"
echo "echo "$pubkey" >/config/auth/wg.pub"
echo "echo "$psk" >/config/auth/wg.psk"
echo "configure"
echo "set interfaces wireguard wg0 address "$address"/31"
echo "set interfaces wireguard wg0 listen-port 51820"
echo "set interfaces wireguard wg0 peer "$pfsensepubkey" endpoint vpn.jbeez.net:"$remport
echo "set interfaces wireguard wg0 peer "$pfsensepubkey" allowed-ips 172.16.0.0/12"
echo "set interfaces wireguard wg0 peer "$pfsensepubkey" allowed-ips 10.0.0.0/8"
echo "set interfaces wireguard wg0 peer "$pfsensepubkey" allowed-ips 192.168.0.0/16"
echo "set interfaces wireguard wg0 peer "$pfsensepubkey" preshared-key /config/auth/wg.psk"
echo "set interfaces wireguard wg0 private-key /config/auth/wg.key"
echo "set interfaces wireguard wg0 route-allowed-ips false"
echo "set protocols static route 172.22.0.0/16 next-hop 10.150.0."$pfquad
echo "set protocols static route 10.150.0.0/24 next-hop 10.150.0."$pfquad
echo "commit; save; exit"
