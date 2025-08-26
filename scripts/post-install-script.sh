#!/bin/bash

# 1. Run PVE post-install script
echo "Running post-install script\n"
echo "DO NOT REBOOT WHEN PROMPTED\n"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pve-install.sh)"

# 2. Network configuration
echo "Importing network config...\n"
wget -O /etc/network/interfaces.new https://raw.githubusercontent.com/andrea-artuso/homelab/refs/heads/main/config/etc-network-interfaces.txt 
echo "Check network config...\n"
ifup -a -i /etc/network/interfaces.new --no-act
echo "Applying network config...\n"
mv /etc/network/interfaces.new /etc/network/interfaces
ifreload -a

# 3. Setup NGINX Proxy
## Install NGINX
apt install nginx
rm /etc/nginx/sites-enabled/default
## Import config
wget -O /etc/nginx/conf.d/proxmox.conf https://raw.githubusercontent.com/andrea-artuso/homelab/refs/heads/main/config/pve-nginx-proxy.conf
nginx -t
## Set service startup priority (after pve-cluster for certs)
mkdir -p /etc/systemd/system/nginx.service.d
cat > /etc/systemd/system/nginx.service.d/override.conf << 'EOF'
[Unit]
Requires=pve-cluster.service
After=pve-cluster.service
EOF
systemctl daemon-reload
systemctl restart nginx

# 4. Reboot system
echo "Rebooting now...\n"
reboot
