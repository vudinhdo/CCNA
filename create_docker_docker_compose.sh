#!/bin/bash

# Cập nhật và nâng cấp hệ thống
sudo apt update && sudo apt upgrade -y

# Cài đặt Docker
sudo apt install -y docker.io

# Khởi động và bật Docker khi khởi động lại
sudo systemctl start docker
sudo systemctl enable docker

# Cài đặt Docker Compose
sudo apt install -y docker-compose

# Kiểm tra phiên bản Docker và Docker Compose
docker --version
docker-compose --version
