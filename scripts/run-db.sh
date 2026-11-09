#!/usr/bin/env bash
# Bài tập 1: khởi chạy container PostgreSQL 15-alpine (detached mode)
set -e

# Xóa container cũ (nếu có) để làm lại từ đầu
docker rm -f quickbite-db 2>/dev/null || true

docker run -d \
  --name quickbite-db \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=12345678 \
  postgres:15-alpine

echo "---- docker ps ----"
docker ps
echo "---- docker images ----"
docker images
