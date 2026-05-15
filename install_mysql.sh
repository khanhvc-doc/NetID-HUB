#!/bin/bash
set -e

echo "================================================================"
echo " INSTALL MYSQL (DOCKER - /data)"
echo "================================================================"

# ===== CONFIG =====
MYSQL_ROOT_PASSWORD="root123"
MYSQL_DATABASE="radius"
MYSQL_USER="radius"
MYSQL_PASSWORD="radius123"

# ===== STEP 1: Tạo thư mục =====
echo "[1/5] Tạo thư mục dữ liệu..."

sudo mkdir -p /data/db/mysql
sudo mkdir -p /data/logs/mysql

# Permission (MySQL container dùng UID 999)
sudo chown -R 999:999 /data/db/mysql
sudo chown -R 999:999 /data/logs/mysql

# ===== STEP 2: Xóa container cũ nếu có =====
echo "[2/5] Kiểm tra container cũ..."

if docker ps -a --format '{{.Names}}' | grep -q "^mysql$"; then
  echo "-> Đã tồn tại container mysql, tiến hành xóa..."
  docker rm -f mysql
fi

# ===== STEP 3: Run container =====
echo "[3/5] Khởi tạo MySQL container..."

docker run -d \
  --name mysql \
  --restart unless-stopped \
  -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
  -e MYSQL_DATABASE=${MYSQL_DATABASE} \
  -e MYSQL_USER=${MYSQL_USER} \
  -e MYSQL_PASSWORD=${MYSQL_PASSWORD} \
  -v /data/db/mysql:/var/lib/mysql \
  -v /data/logs/mysql:/var/log/mysql \
  -p 3306:3306 \
  mysql:8

# ===== STEP 4: Chờ MySQL start =====
echo "[4/5] Đợi MySQL khởi động..."

echo "Đợi MySQL ready..."

for i in {1..30}; do
  if docker exec mysql mysqladmin ping -h "127.0.0.1" -u root -p${MYSQL_ROOT_PASSWORD} --silent; then
    echo "MySQL is ready!"
    break
  fi
  sleep 2
done

# ===== STEP 5: Kiểm tra =====
echo "[5/5] Kiểm tra trạng thái..."

docker ps | grep mysql || { echo "❌ MySQL chưa chạy"; exit 1; }

echo ""
echo "Kiểm tra DB:"
docker exec mysql mysql -h 127.0.0.1 -u root -p${MYSQL_ROOT_PASSWORD} -e "SHOW DATABASES;"

echo ""
echo "================================================================"
echo " ✅ MySQL đã sẵn sàng!"
echo " DB      : ${MYSQL_DATABASE}"
echo " User    : ${MYSQL_USER}"
echo "================================================================"