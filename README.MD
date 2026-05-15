# NETID HUB - GIẢI PHÁP QUẢN LÝ TẬP TRUNG
## I. CẤU TRÚC - MAPPING

### 1. YÊU CẦU:

- RAM: 12 Gb
- vCPU: 6
- Card mạng: 1 - Brigde (nếu vmware)
- Cấu trúc disk/đĩa

```bash
/dev/sda → OS disk (40GB) - Chỉ hệ điều hành Ubuntu OS
/dev/sdb → DATA disk (200GB) 
```

### 2. CHI TIẾT TỪNG ĐĨA:

#### 2.1. Disk 1 – OS (40GB)

```bash
/dev/sda
├── /boot     ~2GB
├── /         ~30GB   ← Ubuntu + system
└── swap      ~8GB
/dev/sda (40GB)
└── /
  ├── /etc
  ├── /usr
  ├── /var        
  └── docker binary
```

#### 2.2. Disk 2 – DATA (200GB)

```bash
/dev/sdb (200GB)
└── /data
    ├── docker/                ← toàn bộ container runtime
    ├── db/
    │   └── mysql/             ← data DB
    ├── kea/                   ← config + lease
    ├── radius/                ← config
    ├── logs/
    │   ├── mysql/
    │   ├── radius/
    │   └── kea/
    ├── backup/ 
    │   └── mysql/ 
    ├── web/
    │   ├── proxy/         ← reverse proxy (nginx/traefik)
    │   ├── daloradius/
    │   ├── phpipam/
    │   └── stork/
```
#### 2.3 Phân bổ tài nguyên từng service

- **PHASE 1**: RADIUS + GUI (daloRADIUS)
  - Auth user
  - Gán VLAN
  - Quản lý user qua GUI 

  - **Tài nguyên:**
    - RAM: 4 Gb
    - vCPU: 4

- **PHASE 2**: phpIPAM
  - Quản lý subnet
  - Mapping IP logic
  - Chuẩn bị cho DHCP

  - **Tài nguyên:**
    - RAM: 1 Gb
    - vCPU: +1 (shared)

- **PHASE 3**: DHCP + GUI (Kea Stork)
  - Cấp IP thật
  - Tracking IP ↔ MAC
  - Monitor DHCP

  - **Tài nguyên:**
    - RAM: 2 Gb
    - vCPU: dùng chung hệ thống

## II. CHUẨN BỊ
**Cài Ubuntu và thêm HDD**
Tham khảo tại mục **II. CHUẨN BỊ** của link https://github.com/khanhvc-doc/zabbix

## III. CÀI ĐẶT

### 👉 1. Cài docker và test

- Cài đặt
```bash
curl -s https://raw.githubusercontent.com/khanhvc-doc/NetID-HUB/refs/heads/master/install_docker.sh | sudo bash
```

- Test
```bash
docker run hello-world
docker compose version
```

### 👉 2. [PHASE 1](Help/PHASE-1/Readme.md)

### 👉 3. [PHASE 2](Help/PHASE-2/Readme.md)

### 👉 4.[PHASE 3](Help/PHASE-3/Readme.md)