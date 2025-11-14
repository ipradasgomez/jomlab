#!/usr/bin/env bash
set -e

echo "🚀 Instalando Docker y Docker Compose (plugin oficial)..."

# 1️⃣ Eliminar versiones antiguas
sudo apt remove -y docker docker-engine docker.io containerd runc || true

# 2️⃣ Instalar dependencias
sudo apt update -y
sudo apt install -y ca-certificates curl gnupg lsb-release

# 3️⃣ Añadir clave GPG y repositorio oficial
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4️⃣ Instalar Docker Engine, CLI, containerd, buildx y compose
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5️⃣ Habilitar e iniciar Docker
sudo systemctl enable docker
sudo systemctl start docker

# 6️⃣ Agregar el usuario actual al grupo docker
sudo usermod -aG docker $USER

echo "✅ Docker y Docker Compose se han instalado correctamente."
echo "🔄 Es necesario cerrar sesión o ejecutar 'newgrp docker' para usar Docker sin sudo."
echo ""
echo "Versión de Docker instalada:"
docker --version || echo "Aún no disponible hasta reiniciar la sesión."
echo ""
echo "Versión de Docker Compose:"
docker compose version || echo "Aún no disponible hasta reiniciar la sesión."
