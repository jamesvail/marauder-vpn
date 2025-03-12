#!/bin/bash
set -e

CONFIG_DIR="/config/shadowsocks"
SS_PASSWORD=$(openssl rand -base64 32 | tr -d '/+=' | cut -c1-16)

# CONFIG.JSON
# configures sock's port and mode
# send eth0 to port 8388

cat > "${CONFIG_DIR}/config.json" << EOF
{
    "server": "0.0.0.0",
    "server_port": 8388,
    "password": "${SS_PASSWORD}",
    "timeout": 300,
    "method": "chacha20-ietf-poly1305",
    "fast_open": true,
    "mode": "tcp_and_udp"
}
EOF

# CLIENT TEMPLATE
cat > "${CONFIG_DIR}/client_template.json" << EOF
{
    "server": "SERVER_IP",
    "server_port": 8388,
    "password": "${SS_PASSWORD}",
    "timeout": 300,
    "method": "chacha20-ietf-poly1305",
    "mode": "tcp_and_udp",
    "local_address": "127.0.0.1",
    "local_port": 1080
}
EOF

# update iptables rules
cat > "${CONFIG_DIR}/wg-ss-integration.sh" << 'EOF'
#!/bin/bash
# Integration script to use WireGuard as the 'relay' and Shadowsocks as the endpoint.

sysctl -w net.ipv4.ip_forward=1

iptables -t nat -A PREROUTING -p tcp --dport 51820 -j REDIRECT --to-ports 8388
iptables -t nat -A PREROUTING -p udp --dport 51820 -j REDIRECT --to-ports 8388

echo "wg-ss-integration ran."
EOF

chmod +x "${CONFIG_DIR}/wg-ss-integration.sh"

echo "Shadowsocks configuration generated."
echo "Password: ${SS_PASSWORD}"
echo "Important: Save this password for client configuration"