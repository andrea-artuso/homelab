#!/bin/bash

# 1. Run PVE post-install script
echo "Running post-install script\n"
echo "DO NOT REBOOT WHEN PROMPTED\n"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pve-install.sh)"

# 2. Network configuration
echo "Importing network config...\n"
wget -O /etc/pve/interfaces.new https://raw.githubusercontent.com/andrea-artuso/homelab/refs/heads/main/config/etc-network-interfaces.txt 
echo "Check network config...\n"
ifup -a -i /etc/pve/interfaces.new --no-act
echo "Applying network config...\n"
mv /etc/pve/interfaces.new /etc/pve/interfaces
ifreload -a

# 3. Setup NGINX Proxy
apt install nginx
rm /etc/nginx/sites-enabled/default
wget -O /etc/nginx/conf.d/proxmox.conf https://raw.githubusercontent.com/andrea-artuso/homelab/refs/heads/main/config/pve-nginx-proxy.conf
nginx -t
systemctl restart nginx

# 4. Reboot system
echo "Rebooting now...\n"
reboot
