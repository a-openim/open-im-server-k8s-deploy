# OpenIM Services Connection Document

This document provides connection details for the OpenIM infrastructure services deployed via Docker Compose on node IP `10.88.88.13`.

## Prerequisites
- Docker Compose is running on the host with IP `10.88.88.13`
- All services are accessible via the exposed ports on the host IP
- Authentication credentials are set via environment variables in the Docker Compose file

## MongoDB

**Service Name:** mongo  
**Container Name:** mongo  
**Image:** `${MONGO_IMAGE}`  
**Port:** 27017 (exposed on host)  
**Connection String:** `mongodb://<username>:<password>@10.88.88.13:27017/openim_v3`  
**Authentication:**  
- Root User: `root` (password: `openIM123`)  
- OpenIM User: `${MONGO_USERNAME}` (password: `${MONGO_PASSWORD}`)  
- Database: `openim_v3`  
- Role: readWrite on `openim_v3` database  

**Internal Connection (within Docker network):** `mongodb://<username>:<password>@mongo:27017/openim_v3`

## Redis

**Service Name:** redis  
**Container Name:** openim-redis  
**Image:** `${REDIS_IMAGE}`  
**Port:** Not exposed externally (internal only)  
**Connection String:** `redis://:<password>@openim-redis:6379`  
**Authentication:**  
- Password: `${REDIS_PASSWORD}`  
- Append Only: Yes  

**Note:** Redis is not exposed externally. Access is only available within the Docker network using the container name `openim-redis`.

## etcd

**Service Name:** etcd  
**Container Name:** etcd  
**Image:** `${ETCD_IMAGE}`  
**Ports:**  
- Client: 12379 (exposed on host, maps to 2379 internal)  
- Peer: 12380 (exposed on host, maps to 2380 internal)  
**Connection String:** `http://10.88.88.13:12379`  
**Authentication:**  
- Optional authentication can be enabled by setting environment variables:  
  - Root User: `${ETCD_ROOT_USER}` (default commented: root)  
  - Root Password: `${ETCD_ROOT_PASSWORD}` (default commented: openIM123)  
  - OpenIM User: `${ETCD_USERNAME}` (default commented: openIM)  
  - OpenIM Password: `${ETCD_PASSWORD}` (default commented: openIM123)  

**Internal Connection (within Docker network):** `http://etcd:2379`

## Zookeeper

**Service Name:** zookeeper  
**Container Name:** zookeeper  
**Image:** bitnami/zookeeper:3.8.1  
**Port:** 2181 (exposed on host)  
**Connection String:** `10.88.88.13:2181`  
**Authentication:** None configured  

**Internal Connection (within Docker network):** `zookeeper:2181`

## Kafka

**Service Name:** kafka  
**Container Name:** kafka  
**Image:** `${KAFKA_IMAGE}`  
**Port:** 9094 (external listener, exposed on host)  
**Connection String:** `10.88.88.13:9094`  
**Authentication:**  
- SASL_PLAINTEXT enabled  
- Username: `${KAFKA_USERNAME}`  
- Password: `${KAFKA_PASSWORD}`  
**Listeners:**  
- PLAINTEXT: kafka:9092 (internal)  
- EXTERNAL: kafka:9094 (external)  

**Internal Connection (within Docker network):** `kafka:9092`

## MinIO

**Service Name:** minio  
**Container Name:** minio  
**Image:** `${MINIO_IMAGE}`  
**Ports:**  
- API: `${MINIO_PORT}:9000` (exposed on host)  
- Console: `${MINIO_CONSOLE_PORT}:9090` (exposed on host)  
**Connection String:**  
- API: `http://10.88.88.13:${MINIO_PORT}`  
- Console: `http://10.88.88.13:${MINIO_CONSOLE_PORT}`  
**Authentication:**  
- Root User: `${MINIO_ACCESS_KEY_ID}`  
- Root Password: `${MINIO_SECRET_ACCESS_KEY}`  

**Internal Connection (within Docker network):**  
- API: `http://minio:9000`  
- Console: `http://minio:9090`

## Environment Variables Reference

The following environment variables need to be set for proper authentication:

- `MONGO_USERNAME` - MongoDB OpenIM user  
- `MONGO_PASSWORD` - MongoDB OpenIM password  
- `REDIS_PASSWORD` - Redis password  
- `ETCD_USERNAME` - etcd OpenIM user (optional)  
- `ETCD_PASSWORD` - etcd OpenIM password (optional)  
- `ETCD_ROOT_USER` - etcd root user (optional)  
- `ETCD_ROOT_PASSWORD` - etcd root password (optional)  
- `KAFKA_USERNAME` - Kafka SASL user  
- `KAFKA_PASSWORD` - Kafka SASL password  
- `MINIO_ACCESS_KEY_ID` - MinIO root user  
- `MINIO_SECRET_ACCESS_KEY` - MinIO root password  
- `MINIO_PORT` - MinIO API port on host  
- `MINIO_CONSOLE_PORT` - MinIO console port on host  

## Network

All services are connected via the `openim` Docker network (bridge driver). Internal service discovery uses container names.

## Volumes

Data persistence is achieved through host-mounted volumes under `${DATA_DIR}/components/`:
- MongoDB: `${DATA_DIR}/components/mongodb/`  
- Redis: `${DATA_DIR}/components/redis/`  
- etcd: `${DATA_DIR}/components/etcd/`  
- Zookeeper: `${DATA_DIR}/components/zookeeper/`  
- Kafka: `${DATA_DIR}/components/kafka/`  
- MinIO: `${DATA_DIR}/components/mnt/`  

## Health Checks and Dependencies

- Services have restart policies set to `always`
- Kafka depends on Zookeeper
- OpenIM services (not included in this deployment) depend on all these infrastructure services

## Security Notes

- MongoDB, Redis, etcd (optional), and Kafka have authentication enabled
- MinIO uses root credentials
- Zookeeper has no authentication
- External ports are exposed - consider firewall rules for production
- etcd authentication is optional and commented out by default