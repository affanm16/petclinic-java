#!/bin/bash

# Pet Clinic Deployment Script for EC2
# This script handles Docker container deployment on EC2 instance

set -e  # Exit on error

DOCKER_IMAGE=$1
BUILD_NUMBER=$2
CONTAINER_NAME="petclinic"
APP_PORT=8081

echo "================================================"
echo "Starting Pet Clinic Deployment"
echo "Image: ${DOCKER_IMAGE}"
echo "Build: ${BUILD_NUMBER}"
echo "================================================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Installing Docker..."
    sudo yum update -y
    sudo yum install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    echo "✅ Docker installed successfully"
fi

# Start Docker service if not running
if ! sudo systemctl is-active --quiet docker; then
    echo "Starting Docker service..."
    sudo systemctl start docker
fi

# Load Docker image from tar file
echo "Loading Docker image from tar file..."
if [ -f "/tmp/petclinic-${BUILD_NUMBER}.tar.gz" ]; then
    docker load < /tmp/petclinic-${BUILD_NUMBER}.tar.gz
    echo "✅ Docker image loaded successfully"
    # Clean up tar file
    rm -f /tmp/petclinic-${BUILD_NUMBER}.tar.gz
else
    echo "❌ Error: Image tar file not found at /tmp/petclinic-${BUILD_NUMBER}.tar.gz"
    exit 1
fi

# Stop and remove existing container if running
if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
    echo "Stopping existing container..."
    docker stop ${CONTAINER_NAME}
fi

if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    echo "Removing existing container..."
    docker rm ${CONTAINER_NAME}
fi

# Run new container
echo "Starting new container..."
docker run -d \
    --name ${CONTAINER_NAME} \
    --restart unless-stopped \
    -p ${APP_PORT}:${APP_PORT} \
    -e SPRING_DATASOURCE_URL="jdbc:mysql://localhost:3306/pet_clinic?useSSL=false" \
    -e SPRING_DATASOURCE_USERNAME="root" \
    -e SPRING_DATASOURCE_PASSWORD="Root123$" \
    ${DOCKER_IMAGE}

# Wait for container to be healthy
echo "Waiting for application to start..."
sleep 15

# Health check
if curl -f http://localhost:${APP_PORT}/actuator/health > /dev/null 2>&1; then
    echo "✅ Application is healthy!"
else
    echo "⚠️  Warning: Health check failed, but container is running"
fi

# Show container status
echo "================================================"
echo "Container Status:"
docker ps -f name=${CONTAINER_NAME}
echo "================================================"

# Clean up old images
echo "Cleaning up old images..."
docker image prune -f

echo "✅ Deployment completed successfully!"
echo "Application accessible at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):${APP_PORT}"
