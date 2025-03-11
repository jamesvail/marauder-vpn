#!/bin/bash
set -e

CONFIG_DIR="/config/wireguard"
SERVER_DIR="${CONFIG_DIR}/server"
WG_INTERFACE="wg0"


mkdir -p ${SERVER_DIR}

# server key gen, stored in config
if [ ! -f "${SERVER_DIR}/privatekey" ]; then
  echo "Generating your server keys......"
  wg genkey | tee "${SERVER_DIR}/privatekey" | wg pubkey > "${SERVER_DIR}/publickey"
fi

PRIVATE_KEY=$(cat "${SERVER_DIR}/privatekey")
PUBLIC_KEY=$(cat "${SERVER_DIR}/publickey")

# create interface config file
# only need interface, peers added via user manager.
cat > "${CONFIG_DIR}/wg0.conf" << EOF
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = ${PRIVATE_KEY}
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOF

echo "Your Marauder Configuration is...."
echo "Complete!"
echo "Your Public Key: ${PUBLIC_KEY}"
echo "IP Address: 10.0.0.1/24"