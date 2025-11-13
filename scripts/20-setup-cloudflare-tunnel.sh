#!/bin/bash
# Script de configuración automática del túnel de Cloudflare
# Uso: ./20-setup-cloudflare-tunnel.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Configuración Automática del Túnel de Cloudflare ===${NC}"
echo ""

# Determinar la raíz del proyecto
# El script asume que el .env siempre existe en la raíz del proyecto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$SCRIPT_DIR" == *"/scripts" ]]; then
    # Si el script está en scripts/, la raíz está un nivel arriba
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
else
    # Si se ejecuta desde otro lugar, asumir que estamos en la raíz
    PROJECT_ROOT="$(cd "$SCRIPT_DIR" && pwd)"
fi

ENV_FILE="$PROJECT_ROOT/.env"

# Verificar que el .env existe en la raíz
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}Error: No se encuentra el archivo .env en la raíz del proyecto${NC}"
    echo "El archivo .env debe existir en: $PROJECT_ROOT/.env"
    exit 1
fi

# Función para actualizar variables en .env
update_env() {
    local key=$1
    local value=$2
    if grep -q "^${key}=" "$ENV_FILE" 2>/dev/null; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
    else
        echo "${key}=${value}" >> "$ENV_FILE"
    fi
}

# Función para leer una variable del .env
get_env_var() {
    local key=$1
    # Buscar la línea que no esté comentada y tenga la clave
    grep -E "^[[:space:]]*${key}[[:space:]]*=" "$ENV_FILE" 2>/dev/null | \
        grep -v "^[[:space:]]*#" | \
        head -1 | \
        sed 's/^[^=]*=[[:space:]]*//' | \
        sed 's/[[:space:]]*$//' | \
        sed 's/^"//;s/"$//' | \
        sed "s/^'//;s/'$//"
}

# Función para pedir una variable si no está definida o está vacía
prompt_if_missing() {
    local key=$1
    local prompt_text=$2
    local example_text=$3
    local value=$(get_env_var "$key")
    
    # Limpiar valores de ejemplo (que empiezan con "your" o contienen "example")
    if [[ "$value" =~ ^(your|example|here|_here) ]] || [[ -z "$value" ]] || [[ "$value" == *"example"* ]]; then
        value=""
    fi
    
    if [ -z "$value" ]; then
        if [ -n "$example_text" ]; then
            read -p "${prompt_text} (ej: ${example_text}): " value
        else
            read -p "${prompt_text}: " value
        fi
        if [ -z "$value" ]; then
            echo -e "${RED}Error: ${key} es requerido${NC}" >&2
            exit 1
        fi
        update_env "$key" "$value"
        echo "$value" >&1
    else
        echo -e "${GREEN}✓ ${key} ya está definido en .env${NC}" >&2
        echo "$value" >&1
    fi
}

echo -e "${BLUE}Verificando variables de entorno...${NC}"
echo ""

# Leer o solicitar variables necesarias
DOMAIN=$(prompt_if_missing "MAIN_DOMAIN" "1. Tu dominio" "tudominio.com")
CF_EMAIL=$(prompt_if_missing "CF_API_EMAIL" "2. Email de Cloudflare" "tu@email.com")
CF_API_KEY=$(prompt_if_missing "CF_API_KEY" "3. API Key de Cloudflare (obtener en: Profile > API Tokens > Global API Key)" "")
TUNNEL_TOKEN=$(prompt_if_missing "CLOUDFLARE_TUNNEL_TOKEN" "4. Token del túnel de Cloudflare (obtener en: Zero Trust > Networks > Tunnels > Create tunnel)" "")
ACME_EMAIL=$(prompt_if_missing "ACME_EMAIL" "5. Email para certificados Let's Encrypt" "tu@email.com")

echo ""
echo -e "${YELLOW}Configurando...${NC}"

# Obtener Account ID y Tunnel ID
echo ""
echo -e "${BLUE}Obteniendo información de Cloudflare...${NC}"

ZONE_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
    -H "X-Auth-Email: $CF_EMAIL" \
    -H "X-Auth-Key: $CF_API_KEY" \
    -H "Content-Type: application/json")

ZONE_ID=$(echo "$ZONE_RESPONSE" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -z "$ZONE_ID" ]; then
    echo -e "${RED}Error: No se pudo obtener el Zone ID. Verifica tus credenciales.${NC}"
    exit 1
fi

ACCOUNT_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts" \
    -H "X-Auth-Email: $CF_EMAIL" \
    -H "X-Auth-Key: $CF_API_KEY" \
    -H "Content-Type: application/json")

ACCOUNT_ID=$(echo "$ACCOUNT_RESPONSE" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

# Extraer Tunnel ID del token
TUNNEL_ID=$(echo "$TUNNEL_TOKEN" | base64 -d 2>/dev/null | grep -o '"t":"[^"]*' | cut -d'"' -f4 || echo "")

if [ -z "$TUNNEL_ID" ]; then
    echo -e "${YELLOW}No se pudo extraer el Tunnel ID del token.${NC}"
    echo "Por favor, proporciona el Tunnel ID manualmente:"
    read -p "Tunnel ID: " TUNNEL_ID
fi

echo -e "${GREEN}✓ Información obtenida${NC}"

# Configurar config.yml de cloudflared
echo ""
echo -e "${BLUE}Configurando cloudflared...${NC}"

CLOUDFLARED_CONFIG="$PROJECT_ROOT/services/cloudflared/config.yml"
mkdir -p "$(dirname "$CLOUDFLARED_CONFIG")"

cat > "$CLOUDFLARED_CONFIG" <<EOF
# Configuración de Cloudflare Tunnel
ingress:
  - hostname: "*.${DOMAIN}"
    service: https://traefik:443
    originRequest:
      noTLSVerify: true
      originServerName: "*.${DOMAIN}"
  - service: http_status:404
EOF

echo -e "${GREEN}✓ config.yml creado${NC}"

# Eliminar registro A existente si existe
echo ""
echo -e "${BLUE}Configurando DNS...${NC}"

EXISTING_A=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=*.${DOMAIN}" \
    -H "X-Auth-Email: $CF_EMAIL" \
    -H "X-Auth-Key: $CF_API_KEY" \
    -H "Content-Type: application/json")

A_RECORD_ID=$(echo "$EXISTING_A" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -n "$A_RECORD_ID" ]; then
    curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$A_RECORD_ID" \
        -H "X-Auth-Email: $CF_EMAIL" \
        -H "X-Auth-Key: $CF_API_KEY" \
        -H "Content-Type: application/json" > /dev/null
    echo -e "${GREEN}✓ Registro A eliminado${NC}"
fi

# Crear o actualizar CNAME
EXISTING_CNAME=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=CNAME&name=*.${DOMAIN}" \
    -H "X-Auth-Email: $CF_EMAIL" \
    -H "X-Auth-Key: $CF_API_KEY" \
    -H "Content-Type: application/json")

CNAME_RECORD_ID=$(echo "$EXISTING_CNAME" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -n "$CNAME_RECORD_ID" ]; then
    curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$CNAME_RECORD_ID" \
        -H "X-Auth-Email: $CF_EMAIL" \
        -H "X-Auth-Key: $CF_API_KEY" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"CNAME\",\"name\":\"*\",\"content\":\"${TUNNEL_ID}.cfargotunnel.com\",\"proxied\":true}" > /dev/null
    echo -e "${GREEN}✓ CNAME actualizado${NC}"
else
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
        -H "X-Auth-Email: $CF_EMAIL" \
        -H "X-Auth-Key: $CF_API_KEY" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"CNAME\",\"name\":\"*\",\"content\":\"${TUNNEL_ID}.cfargotunnel.com\",\"proxied\":true}" > /dev/null
    echo -e "${GREEN}✓ CNAME creado${NC}"
fi

# Configurar Public Hostname en el túnel
echo ""
echo -e "${BLUE}Configurando Public Hostname en el túnel...${NC}"

INGRESS_CONFIG="{\"config\":{\"ingress\":[{\"hostname\":\"*.${DOMAIN}\",\"service\":\"https://traefik:443\",\"originRequest\":{\"noTLSVerify\":true,\"originServerName\":\"*.${DOMAIN}\"}},{\"service\":\"http_status:404\"}]}}"

UPDATE_RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/configurations" \
    -H "X-Auth-Email: $CF_EMAIL" \
    -H "X-Auth-Key: $CF_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$INGRESS_CONFIG")

if echo "$UPDATE_RESPONSE" | grep -q '"success":true'; then
    echo -e "${GREEN}✓ Public Hostname configurado${NC}"
else
    echo -e "${YELLOW}⚠ No se pudo configurar el Public Hostname automáticamente${NC}"
    echo "   Puedes configurarlo manualmente en: Zero Trust > Networks > Tunnels > [Tu Túnel] > Configure"
fi

# Iniciar servicios
echo ""
echo -e "${BLUE}Iniciando servicios...${NC}"

cd "$PROJECT_ROOT/services"

# Crear red si no existe
docker network inspect entry >/dev/null 2>&1 || docker network create entry

# Iniciar Cloudflared primero (el túnel debe estar listo antes que Traefik)
cd cloudflared
docker compose up -d >/dev/null 2>&1 || docker-compose up -d >/dev/null 2>&1
echo -e "${GREEN}✓ Cloudflared iniciado${NC}"

# Iniciar Traefik después (se conecta al túnel)
cd ../traefik
docker compose up -d >/dev/null 2>&1 || docker-compose up -d >/dev/null 2>&1
echo -e "${GREEN}✓ Traefik iniciado${NC}"

echo ""
echo -e "${BLUE}=== Configuración Completada ===${NC}"
echo ""
echo -e "${GREEN}✓ Túnel configurado y funcionando${NC}"
echo -e "${GREEN}✓ DNS configurado${NC}"
echo -e "${GREEN}✓ Servicios iniciados${NC}"
echo ""
echo "Espera 1-2 minutos para que los DNS se propaguen."
echo ""
echo "Para ver los logs:"
echo "  docker logs cloudflared"
echo "  docker logs traefik"

