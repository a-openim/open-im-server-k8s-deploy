# OpenIM Docker Compose Services Documentation

This document analyzes and compares the services defined in two Docker Compose files for the OpenIM project:

1. `docker-compose copy.yaml` - A comprehensive configuration with OpenIM-specific services
2. `docker-compose.yaml` - A basic infrastructure setup

## Services in `docker-compose copy.yaml`

This file contains 9 active services plus several commented monitoring services. It appears to be a production-ready setup with authentication, health checks, and dependencies.

### Active Services

| Service Name | Description | Key Features |
|--------------|-------------|--------------|
| `mongo` | MongoDB database service | - Uses custom MongoDB image with authentication setup<br>- Creates OpenIM user with readWrite role<br>- WiredTiger cache size configuration<br>- Persistent volumes for data, logs, and config |
| `redis` | Redis cache service | - Custom Redis image with password protection<br>- Append-only file enabled<br>- Persistent volume for data<br>- Sysctl configuration for network connections |
| `etcd` | etcd key-value store | - Custom etcd image with authentication setup<br>- Supports optional authentication with root and OpenIM users<br>- Role-based permissions for OpenIM operations<br>- Persistent volume for data |
| `kafka` | Kafka message broker | - Custom Kafka image with SASL authentication<br>- Configured as controller and broker<br>- External listener on port 9094 with SASL_PLAINTEXT<br>- Persistent volume for data |
| `minio` | MinIO object storage | - Custom MinIO image<br>- Root user and password configuration<br>- Console access on port 9090<br>- Persistent volumes for data and config |
| `openim-web-front` | OpenIM web frontend | - Web interface container<br>- Exposed on configurable port<br>- No additional configuration |
| `openim-admin-front` | OpenIM admin frontend | - Admin web interface container<br>- Exposed on configurable port<br>- No additional configuration |
| `openim-server` | OpenIM server | - Main OpenIM server application<br>- Health check with `mage check`<br>- Environment variables for all infrastructure connections<br>- Depends on all infrastructure services<br>- Ports for message gateway (10001) and API (10002) |
| `openim-chat` | OpenIM chat service | - Chat functionality service<br>- Health check with `mage check`<br>- Environment variables for infrastructure<br>- Ports for chat API (10008) and admin API (10009)<br>- Depends on all services including openim-server |

### Commented Services

The file also contains commented-out monitoring services:
- `prometheus` - Metrics collection
- `alertmanager` - Alert management
- `grafana` - Visualization dashboard
- `node-exporter` - System metrics exporter

## Services in `docker-compose.yaml`

This file contains 5 basic infrastructure services. It appears to be a simpler, development-oriented setup without authentication for most services.

### Services

| Service Name | Description | Key Features |
|--------------|-------------|--------------|
| `zookeeper` | Zookeeper coordination service | - Bitnami Zookeeper 3.8<br>- Basic configuration for single node<br>- Persistent volume for data |
| `kafka` | Kafka message broker | - Bitnami Kafka 3.0.0<br>- Connected to Zookeeper<br>- PLAINTEXT listeners (no authentication)<br>- Auto topic creation enabled<br>- Persistent volume for data |
| `mongodb` | MongoDB database | - Bitnami MongoDB 5.0.0<br>- Root password and user configuration<br>- Default database: openIM<br>- Persistent volume for data |
| `minio` | MinIO object storage | - MinIO release from 2023-03-20<br>- Root user: admin, password: openIMExamplePwd<br>- Console on port 9001<br>- Persistent volume for data |
| `etcd` | etcd key-value store | - Bitnami etcd 3.5.0<br>- No authentication enabled<br>- Persistent volume for data |

## Key Differences

### Architecture
- **docker-compose copy.yaml**: Includes OpenIM application services (openim-server, openim-chat, frontends) and uses custom images with authentication
- **docker-compose.yaml**: Only infrastructure services using standard Bitnami images with minimal authentication

### Authentication & Security
- **docker-compose copy.yaml**: Implements authentication for MongoDB, Redis, etcd, and Kafka
- **docker-compose.yaml**: Most services run without authentication (PLAINTEXT Kafka, no auth etcd)

### Kafka Setup
- **docker-compose copy.yaml**: Uses Kafka 3.x with KRaft mode (no Zookeeper), SASL authentication
- **docker-compose.yaml**: Uses Kafka 3.0.0 with Zookeeper, PLAINTEXT listeners

### Networking
- **docker-compose copy.yaml**: Uses `openim` network
- **docker-compose.yaml**: Uses `openim-network` with named volumes

### Configuration Approach
- **docker-compose copy.yaml**: Uses environment variables extensively for configuration
- **docker-compose.yaml**: Hardcoded values in environment variables

### Use Cases
- **docker-compose copy.yaml**: Production or staging environment with security and monitoring capabilities
- **docker-compose.yaml**: Development or testing environment with simpler setup

## Networks and Volumes

### docker-compose copy.yaml
- **Network**: `openim` (bridge driver)
- **Volumes**: Host-mounted volumes using `${DATA_DIR}` for persistence

### docker-compose.yaml
- **Network**: `openim-network` (bridge driver)
- **Volumes**: Named volumes (zookeeper-data, kafka-data, etc.) with local driver

## Recommendations

- Use `docker-compose copy.yaml` for production deployments requiring security and scalability
- Use `docker-compose.yaml` for quick development setups or testing
- Consider enabling authentication in the basic setup for security in non-development environments
- The commented monitoring services in the copy.yaml can be enabled for production observability