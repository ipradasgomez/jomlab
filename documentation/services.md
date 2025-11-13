# Servicios

Documentación de servicios individuales del homelab.

## Servicios de Infraestructura

### Traefik
Reverse proxy y load balancer.

**Ubicación**: `services/traefik/`

**Función**:
- Enrutamiento basado en hostname
- Terminación SSL/TLS
- Descubrimiento de servicios (cuando funciona)
- Configuración estática en `config/dynamic/`

**Configuración**:
- Estática: `config/traefik.yml`
- Dinámica: `config/dynamic/*.yml`
- Variables: `.env` (raíz)

**Ver logs**: `docker logs traefik`

### Cloudflared
Cliente del túnel de Cloudflare.

**Ubicación**: `services/cloudflared/`

**Función**:
- Crear túnel seguro hacia Cloudflare
- Reenviar tráfico a Traefik
- No requiere puertos abiertos

**Configuración**:
- `config.yml`: Reglas de ingress
- Variables: `.env` (TUNNEL_TOKEN)

**Ver logs**: `docker logs cloudflared`

**Documentación**: Ver `services/cloudflared/README.md`

## Servicios de Aplicación

### Whoami
Servicio de prueba que muestra información de la petición HTTP.

**Ubicación**: `services/whoami/`

**Uso**: Prueba de conectividad y configuración.

**Acceso**: `https://whoami.dominio.com`

### AdGuard Home
Servidor DNS con bloqueo de anuncios.

**Ubicación**: `services/adguardhome/`

**Puertos**:
- DNS: 53 (TCP/UDP)
- Admin: 3000
- HTTP: 8050
- HTTPS: 4430

**Configuración**: Primera vez accede a `http://localhost:3000`

## Añadir un Nuevo Servicio

1. Crear directorio en `services/`
2. Crear `docker-compose.yml` con:
   - Red `entry` (si necesita exposición)
   - `env_file: - ../../.env`
   - Volúmenes a `../../data/<servicio>/`
3. Crear configuración en Traefik si necesita exposición
4. Crear directorio en `data/` si necesita persistencia
5. Documentar en este archivo

## Gestión de Servicios

**Iniciar**:
```bash
cd services/<servicio>
docker compose up -d
```

**Detener**:
```bash
docker compose down
```

**Logs**:
```bash
docker logs <servicio>
# o
docker compose logs -f
```

**Reiniciar**:
```bash
docker compose restart
```

