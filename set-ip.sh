#!/bin/bash

# Detect OS
OS=$(uname -s)

# Get IP address based on OS
if [ "$OS" = "Darwin" ]; then
    # macOS (uses ifconfig)
    IP_ADDRESS=$(ifconfig en0 | grep "inet " | awk '{print $2}')
else
    # Linux (uses ip)
    IP_ADDRESS=$(ip route get 1.1.1.1 | awk '{print $7; exit}')
fi

# Ensure an IP address was found
if [ -z "$IP_ADDRESS" ]; then
    echo "Error: Could not determine IP address."
    exit 1
fi

# Ensure .env file exists
if [ ! -f .env ]; then
    echo "Creating .env file..."
    touch .env
fi

# Update .env file with the IP address
echo "REACT_APP_API_URL=http://$IP_ADDRESS:5003/api" > .env
echo "MONGO_URL=mongodb://$IP_ADDRESS:27017/test2" >> .env

# Allow required ports through ufw
echo "Allowing ports 3001, 5003, and 27017 through ufw..."
sudo ufw allow 3001
sudo ufw allow 5003
sudo ufw allow 27017

# Reload ufw to apply changes (optional but recommended)
sudo ufw reload

echo "Updated .env with IP: $IP_ADDRESS and allowed ports 3001, 5003, and 27017 through ufw."
