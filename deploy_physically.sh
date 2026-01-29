#!/usr/bin/env bash

# Physical Deployment Script for OpenIM Server Infrastructure
# This script deploys infrastructure components using Docker instead of Kubernetes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NETWORK_NAME="openim-network"
MYSQL_ROOT_PASSWORD="openIMExamplePwd"
MONGO_ROOT_PASSWORD="openIMExamplePwd"
REDIS_PASSWORD="openIMExamplePwd"
MINIO_ROOT_USER="admin"
MINIO_ROOT_PASSWORD="openIMExamplePwd"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}OpenIM Server Physical Deployment${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker is installed${NC}"

# Create Docker network
echo ""
echo -e "${YELLOW}Creating Docker network...${NC}"
if ! docker network inspect ${NETWORK_NAME} &> /dev/null; then
    docker network create ${NETWORK_NAME}
    echo -e "${GREEN}✓ Network ${NETWORK_NAME} created${NC}"
else
    echo -e "${GREEN}✓ Network ${NETWORK_NAME} already exists${NC}"
fi

# Function to check if container is running
check_container() {
    local container_name=$1
    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo -e "${YELLOW}Container ${container_name} already exists${NC}"
        return 1
    else
        return 0
    fi
}

# Deploy Zookeeper
echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Deploying Zookeeper...${NC}"
echo -e "${YELLOW}========================================${NC}"

if check_container "zookeeper"; then
    docker run -d \
        --name zookeeper \
        --network ${NETWORK_NAME} \
        -p 2181:2181 \
        -e ZOO_MY_ID=1 \
        -e ZOO_SERVERS=zookeeper:2888:3888 \
        -e ZOO_TICK_TIME=2000 \
        -e ZOO_INIT_LIMIT=5 \
        -e ZOO_SYNC_TICK=2 \
        bitnami/zookeeper:3.8
    echo -e "${GREEN}✓ Zookeeper deployed${NC}"
fi

# Wait for Zookeeper to be ready
echo -e "${YELLOW}Waiting for Zookeeper to be ready...${NC}"
sleep 10

# Deploy Kafka
echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Deploying Kafka...${NC}"
echo -e "${YELLOW}========================================${NC}"

if check_container "kafka"; then
    docker run -d \
        --name kafka \
        --network ${NETWORK_NAME} \
        -p 9092:9092 \
        -p 9093:9093 \
        -e KAFKA_CFG_ZOOKEEPER_CONNECT=zookeeper:2181 \
        -e KAFKA_CFG_LISTENERS=PLAINTEXT://:9092 \
        -e KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://kafka:9092 \
        -e KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE=true \
        -e ALLOW_PLAINTEXT_LISTENER=yes \
        -e KAFKA_CFG_NUM_PARTITIONS=3 \
        -e KAFKA_CFG_NUM_NETWORK_THREADS=3 \
        -e KAFKA_CFG_NUM_IO_THREADS=8 \
        -e KAFKA_CFG_SOCKET_SEND_BUFFER_BYTES=102400 \
        -e KAFKA_CFG_SOCKET_RECEIVE_BUFFER_BYTES=102400 \
        -e KAFKA_CFG_SOCKET_REQUEST_MAX_BYTES=104857600 \
        -e KAFKA_CFG_LOG_RETENTION_HOURS=168 \
        -e KAFKA_CFG_LOG_SEGMENT_BYTES=1073741824 \
        -e KAFKA_CFG_LOG_RETENTION_CHECK_INTERVAL_MS=300000 \
        -e KAFKA_CFG_LOG_CLEANER_ENABLE=true \
        -e KAFKA_CFG_LOG_CLEANER_DELETE_RETENTION_MS=604800000 \
        bitnami/kafka:3.0
    echo -e "${GREEN}✓ Kafka deployed${NC}"
fi

# Wait for Kafka to be ready
echo -e "${YELLOW}Waiting for Kafka to be ready...${NC}"
sleep 15

# Deploy Redis
echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Deploying Redis...${NC}"
echo -e "${YELLOW}========================================${NC}"

# Redis deployment commented out - using existing Redis instance
# if check_container "redis"; then
#     docker run -d \
#         --name redis \
#         --network ${NETWORK_NAME} \
#         -p 6379:6379 \
#         -e REDIS_PASSWORD=${REDIS_PASSWORD} \
#         -e REDIS_AOF_ENABLED=yes \
#         -e REDIS_REPLICATION_MODE=master \
#         -v redis-data:/bitnami/redis/data \
#         bitnami/redis:7.0
#     echo -e "${GREEN}✓ Redis deployed${NC}"
# fi

# Wait for Redis to be ready
# echo -e "${YELLOW}Waiting for Redis to be ready...${NC}"
# sleep 5

# Deploy MySQL
echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Deploying MySQL...${NC}"
echo -e "${YELLOW}========================================${NC}"

# MySQL deployment commented out - using existing MySQL instance
# if check_container "mysql"; then
#     docker run -d \
#         --name mysql \
#         --network ${NETWORK_NAME} \
#         -p 3306:3306 \
#         -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
#         -e MYSQL_DATABASE=openIM_v2 \
#         -e MYSQL_USER=openim \
#         -e MYSQL_PASSWORD=${MYSQL_ROOT_PASSWORD} \
#         -v mysql-data:/bitnami/mysql/data \
#         bitnami/mysql:8.0
#     echo -e "${GREEN}✓ MySQL deployed${NC}"
# fi

# Wait for MySQL to be ready
# echo -e "${YELLOW}Waiting for MySQL to be ready...${NC}"
# sleep 20

# Deploy MongoDB
echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Deploying MongoDB...${NC}"
echo -e "${YELLOW}========================================${NC}"

if check_container "mongodb"; then
    docker run -d \
        --name mongodb \
        --network ${NETWORK_NAME} \
        -p 27017:27017 \
        -e MONGODB_ROOT_PASSWORD=${MONGO_ROOT_PASSWORD} \
        -e MONGODB_USERNAME=root \
        -e MONGODB_PASSWORD=${MONGO_ROOT_PASSWORD} \
        -e MONGODB_DATABASE=openIM \
        -v mongodb-data:/bitnami/mongodb/data \
        bitnami/mongodb:5.0
    echo -e "${GREEN}✓ MongoDB deployed${NC}"
fi

# Wait for MongoDB to be ready
echo -e "${YELLOW}Waiting for MongoDB to be ready...${NC}"
sleep 15

# Deploy MinIO
echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Deploying MinIO...${NC}"
echo -e "${YELLOW}========================================${NC}"

if check_container "minio"; then
    docker run -d \
        --name minio \
        --network ${NETWORK_NAME} \
        -p 9000:9000 \
        -p 9001:9001 \
        -e MINIO_ROOT_USER=${MINIO_ROOT_USER} \
        -e MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD} \
        -v minio-data:/bitnami/minio/data \
        minio/minio:latest server /data --console-address ":9001"
    echo -e "${GREEN}✓ MinIO deployed${NC}"
fi

# Wait for MinIO to be ready
echo -e "${YELLOW}Waiting for MinIO to be ready...${NC}"
sleep 10

# Deploy etcd
echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Deploying etcd...${NC}"
echo -e "${YELLOW}========================================${NC}"

if check_container "etcd"; then
    docker run -d \
        --name etcd \
        --network ${NETWORK_NAME} \
        -p 2379:2379 \
        -p 2380:2380 \
        -e ALLOW_NONE_AUTHENTICATION=yes \
        -e ETCD_ADVERTISE_CLIENT_URLS=http://etcd:2379 \
        -v etcd-data:/bitnami/etcd/data \
        bitnami/etcd:3.5
    echo -e "${GREEN}✓ etcd deployed${NC}"
fi

# Wait for etcd to be ready
echo -e "${YELLOW}Waiting for etcd to be ready...${NC}"
sleep 5

# Display deployment status
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Status${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "zookeeper|kafka|mongodb|minio|etcd"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Service Endpoints:${NC}"
echo -e "  Zookeeper:  localhost:2181"
echo -e "  Kafka:       localhost:9092"
echo -e "  MongoDB:     localhost:27017"
echo -e "  MinIO:       localhost:9000 (API), localhost:9001 (Console)"
echo -e "  etcd:        localhost:2379"
echo ""
echo -e "${YELLOW}Default Credentials:${NC}"
echo -e "  MongoDB Root Password:   ${MONGO_ROOT_PASSWORD}"
echo -e "  MinIO Root User:       ${MINIO_ROOT_USER}"
echo -e "  MinIO Root Password:   ${MINIO_ROOT_PASSWORD}"
echo ""
echo -e "${GREEN}✓ All infrastructure components deployed successfully!${NC}"
