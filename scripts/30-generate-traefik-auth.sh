#!/bin/bash
# Script para generar credenciales de autenticación básica para Traefik

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Uso: $0 <usuario> <contraseña>"
    echo "Ejemplo: $0 admin miPassword123"
    exit 1
fi

USERNAME=$1
PASSWORD=$2

HASH=""

# Intentar usar Docker con imagen ligera (preferido)
if command -v docker &> /dev/null; then
    echo "Usando Docker para generar el hash..."
    HASH=$(docker run --rm httpd:alpine htpasswd -nb "$USERNAME" "$PASSWORD" 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$HASH" ]; then
        echo ""
        echo "Añade esta línea a tu archivo .env:"
        echo "TRAEFIK_BASIC_AUTH=$HASH"
        echo ""
        exit 0
    fi
fi

# Fallback: intentar usar htpasswd del sistema
if command -v htpasswd &> /dev/null; then
    echo "Usando htpasswd del sistema..."
    HASH=$(htpasswd -nb "$USERNAME" "$PASSWORD")
    echo ""
    echo "Añade esta línea a tu archivo .env:"
    echo "TRAEFIK_BASIC_AUTH=$HASH"
    echo ""
    exit 0
fi

# Si llegamos aquí, no hay ninguna opción disponible
echo "Error: No se puede generar el hash."
echo ""
echo "Opciones:"
echo "  1. Instala Docker y ejecuta el script de nuevo"
echo "  2. O instala htpasswd:"
echo "     - Debian/Ubuntu: sudo apt-get install apache2-utils"
echo "     - CentOS/RHEL: sudo yum install httpd-tools"
echo "     - macOS: brew install httpd"
exit 1

