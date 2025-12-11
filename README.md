# VCenter - Enterprise Cluster Management Platform

<div align="center">
  <h1>🏢 VCenter</h1>
  <p><strong>Enterprise Multi-Node & Kubernetes Cluster Management Platform</strong></p>
  
  <p>
    <a href="https://github.com/zsai001/vcenter/releases/latest">
      <img src="https://img.shields.io/github/v/release/zsai001/vcenter?style=flat-square" alt="Latest Release">
    </a>
    <a href="https://github.com/zsai001/vcenter/releases">
      <img src="https://img.shields.io/github/downloads/zsai001/vcenter/total?style=flat-square" alt="Downloads">
    </a>
    <a href="https://github.com/zsai001/vcenter/blob/main/LICENSE">
      <img src="https://img.shields.io/github/license/zsai001/vcenter?style=flat-square" alt="License">
    </a>
  </p>
</div>

```
██╗   ██╗ ██████╗███████╗███╗   ██╗████████╗███████╗██████╗ 
██║   ██║██╔════╝██╔════╝████╗  ██║╚══██╔══╝██╔════╝██╔══██╗
██║   ██║██║     █████╗  ██╔██╗ ██║   ██║   █████╗  ██████╔╝
╚██╗ ██╔╝██║     ██╔══╝  ██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗
 ╚████╔╝ ╚██████╗███████╗██║ ╚████║   ██║   ███████╗██║  ██║
  ╚═══╝   ╚═════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
```

## 📦 Downloads

See [Releases](https://github.com/zsai001/vcenter/releases) for all versions.

### Quick Install (Linux)

```bash
# One-line install (latest version)
curl -sSL https://vcenter.zsoft.cc/install.sh | sudo bash

# Or download manually
curl -LO https://github.com/zsai001/vcenter/releases/latest/download/vcenter-linux.tar.gz
tar -xzvf vcenter-linux.tar.gz
cd vcenter-*
sudo ./install.sh
```

### Manual Start

```bash
# Extract
tar -xzvf vcenter-v*.tar.gz
cd vcenter-v*

# Configure
cp config.yaml.example config.yaml
nano config.yaml  # Edit as needed

# Start
./start.sh
```

## ✨ Features

### 🖥️ Multi-Node Management
- Centralized management of multiple VPanel nodes
- Real-time node status monitoring
- Node grouping and tagging
- Remote command execution
- Agent-based communication with WebSocket

### ☸️ Kubernetes Cluster Management
- Multi-cluster management
- Workload management (Deployments, StatefulSets, DaemonSets)
- Pod management and logs
- Service & Ingress management
- ConfigMaps & Secrets
- Node management (cordon, drain)
- Jobs & CronJobs
- Persistent Volumes & Claims

### 📊 Dashboard & Monitoring
- Unified dashboard for all resources
- Real-time metrics collection
- Historical data analysis
- Alert management

### 🔐 Security
- JWT-based authentication
- Role-based access control (RBAC)
- Audit logging
- VCloud integration for licensing

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        VCloud                                │
│              (User Center, Licensing, API)                   │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          │ License Sync / User Auth
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                        VCenter                               │
│            (Enterprise Cluster Management)                   │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │  Node Manager   │  │   K8s Manager   │                   │
│  └────────┬────────┘  └────────┬────────┘                   │
└───────────┼────────────────────┼────────────────────────────┘
            │                    │
     ┌──────┴──────┐      ┌──────┴──────┐
     │  WebSocket  │      │   K8s API   │
     │   Agents    │      │   Clients   │
     └──────┬──────┘      └──────┬──────┘
            │                    │
     ┌──────┴──────┐      ┌──────┴──────┐
     ▼             ▼      ▼             ▼
┌─────────┐  ┌─────────┐  ┌─────────────────┐
│ VPanel  │  │ VPanel  │  │  K8s Clusters   │
│ Node 1  │  │ Node N  │  │ (EKS/GKE/etc)   │
└─────────┘  └─────────┘  └─────────────────┘
```

## 📁 Release Package Structure

```
vcenter-vX.X.X/
├── bin/                        # Server binaries
│   ├── vcenter-server-linux-amd64
│   └── vcenter-server-linux-arm64
├── docs/                       # Documentation (static HTML)
├── config.yaml.example         # Example configuration
├── start.sh                    # Start script
├── install.sh                  # Installation script
├── vcenter.service             # Systemd service file
└── README.md
```

## 🔧 Configuration

| Environment Variable | Description | Default |
|---------------------|-------------|---------|
| `VCENTER_PORT` | Server port | `8090` |
| `VCENTER_MODE` | Server mode (debug/release) | `release` |
| `VCENTER_DB_DRIVER` | Database driver (sqlite/postgres) | `sqlite` |
| `VCENTER_DB_HOST` | Database host | `localhost` |
| `VCENTER_JWT_SECRET` | JWT signing secret | (auto-generated) |
| `VCENTER_VCLOUD_API_KEY` | VCloud API key | - |

## 📖 Documentation

- [Getting Started](https://vcenter.zsoft.cc/guide/getting-started)
- [Installation Guide](https://vcenter.zsoft.cc/guide/installation)
- [Changelog](https://vcenter.zsoft.cc/changelog)

## 🔗 Related Projects

| Product | Description |
|---------|-------------|
| [VPanel](https://github.com/zsai001/vpanel) | Single-node server management panel |
| [VCloud](https://vcloud.zsoft.cc) | Cloud services & user center |

## 📡 API Endpoints

### Nodes
- `GET /api/v1/nodes` - List all nodes
- `POST /api/v1/nodes` - Add a new node
- `GET /api/v1/nodes/:id` - Get node details
- `PUT /api/v1/nodes/:id` - Update node
- `DELETE /api/v1/nodes/:id` - Delete node

### Kubernetes
- `GET /api/v1/k8s/clusters` - List clusters
- `POST /api/v1/k8s/clusters` - Add cluster
- `GET /api/v1/k8s/clusters/:id` - Get cluster details
- `GET /api/v1/k8s/clusters/:id/namespaces` - List namespaces
- `GET /api/v1/k8s/clusters/:id/pods` - List pods

## 📄 License

Apache License 2.0

---

<div align="center">
  <p>Made with ❤️ by VStaff Team</p>
</div>
