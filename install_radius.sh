#!/bin/bash
set -e

echo "================================================================"
echo " INSTALL FREERADIUS (DOCKER)"
echo "================================================================"

# ===== CONFIG =====
DB_HOST="127.0.0.1"
DB_NAME="radius"
DB_USER="radius"
DB_PASS="radius123"

# ===== STEP 1: Tạo thư mục =====
echo "[1/4] Tạo thư mục..."

sudo mkdir -p /data/radius
sudo mkdir -p /data/logs/radius

# ===== STEP 2: Xóa container cũ =====
echo "[2/4] Xóa container cũ (nếu có)..."

if docker ps -a --format '{{.Names}}' | grep -q "^radius$"; then
  docker rm -f radius
fi

# 2.5
echo "[INIT] Tạo config FreeRADIUS..."

if [ ! -d "/data/freeradius" ]; then
  echo "-> Copy config mặc định từ container..."

  sudo mkdir -p /data/freeradius

  docker run --rm freeradius/freeradius-server:latest \
    tar cf - -C /etc freeradius \
    | tar xf - -C /data

  # Move về đúng path
  if [ -d "/data/etc/freeradius" ]; then
    sudo mv /data/etc/freeradius /data/
    sudo rm -rf /data/etc
  fi

  echo "-> Đã tạo /data/freeradius"
else
  echo "-> Config đã tồn tại, bỏ qua"
fi


# ===== STEP 3: Run FreeRADIUS =====
echo "[3/4] Khởi tạo FreeRADIUS..."

# Đảm bảo config đã tồn tại
if [ ! -f "/data/freeradius/radiusd.conf" ] && [ ! -f "/data/freeradius/3.0/radiusd.conf" ]; then
  echo "❌ Không tìm thấy config FreeRADIUS"
  exit 1
fi

# Đảm bảo quyền (rất quan trọng)
sudo chown -R 0:0 /data/freeradius
sudo chmod -R 755 /data/freeradius

sudo mkdir -p /data/logs/radius
sudo chmod -R 777 /data/logs/radius

# Xóa container cũ nếu có
if docker ps -a --format '{{.Names}}' | grep -q "^radius$"; then
  docker rm -f radius
fi

# Run container (CHẠY DEBUG MODE để thấy log)
docker run -d \
  --name radius \
  --restart unless-stopped \
  -v /data/freeradius:/etc/freeradius \
  -v /data/logs/radius:/var/log/freeradius \
  -p 1812:1812/udp \
  -p 1813:1813/udp \
  freeradius/freeradius-server:latest \
  freeradius -f

# ===== STEP 4: Kiểm tra =====
echo "[4/4] Kiểm tra container..."

docker ps | grep radius || { echo "❌ FreeRADIUS chưa chạy"; exit 1; }

echo ""
echo "================================================================"
echo " ✅ FreeRADIUS đã chạy (chưa config DB)"
echo "================================================================"