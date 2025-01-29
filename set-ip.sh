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

# Update .env file
echo "REACT_APP_API_URL=http://$IP_ADDRESS:5003/api" > .env
echo "MONGO_URL=mongodb://$IP_ADDRESS:27017/test2" >> .env

echo "Updated .env with IP: $IP_ADDRESS"
