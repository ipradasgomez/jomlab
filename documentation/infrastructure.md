# Infraestructura de Entrada

Sistema de entrada del homelab que expone servicios de forma segura sin abrir puertos en el firewall.

## Arquitectura

```
Internet → Cloudflare → Cloudflare Tunnel → Traefik → Servicios
```

### Componentes

**Cloudflare Tunnel (cloudflared)**
- Cliente que crea un túnel seguro hacia Cloudflare
- No requiere abrir puertos en el router
- Tráfico cifrado end-to-end
- Ubicación: `services/cloudflared/`

**Traefik**
- Reverse proxy que gestiona el enrutamiento
- Terminación SSL/TLS
- Descubrimiento automático de servicios (cuando funciona)
- Configuración estática en `config/dynamic/` como fallback
- Ubicación: `services/traefik/`

## Flujo de Tráfico

1. **Cliente externo** accede a `servicio.dominio.com`
2. **Cloudflare DNS** resuelve a `*.dominio.com` → CNAME → `<tunnel-id>.cfargotunnel.com`
3. **Cloudflare Edge** enruta el tráfico por el túnel hacia `cloudflared` local
4. **cloudflared** reenvía a `traefik:443` (red Docker interna)
5. **Traefik** enruta según el hostname hacia el servicio correspondiente
6. **Servicio** responde y el tráfico vuelve por la misma ruta

## Configuración

### Automática (Recomendado)

```bash
cd scripts
./20-setup-cloudflare-tunnel.sh
```

El script configura:
- Variables de entorno (`.env`)
- Configuración de cloudflared (`config.yml`)
- Registros DNS en Cloudflare
- Public Hostname en el túnel
- Inicio de servicios

### Manual

1. **Crear túnel en Cloudflare**:
   - Zero Trust > Networks > Tunnels > Create tunnel
   - Copiar `TUNNEL_TOKEN`

2. **Configurar `.env`**:
   ```
   MAIN_DOMAIN=tu-dominio.com
   CLOUDFLARE_TUNNEL_TOKEN=token_del_tunel
   CF_API_EMAIL=tu-email@example.com
   CF_API_KEY=tu_api_key
   ACME_EMAIL=tu-email@example.com
   ```

3. **Configurar `services/cloudflared/config.yml`**:
   ```yaml
   ingress:
     - hostname: "*.tu-dominio.com"
       service: https://traefik:443
       originRequest:
         noTLSVerify: true
         originServerName: "*.tu-dominio.com"
     - service: http_status:404
   ```

4. **Iniciar servicios** (orden importante: primero Cloudflared, luego Traefik):
   ```bash
   cd services
   docker network inspect entry >/dev/null 2>&1 || docker network create entry
   cd cloudflared && docker compose up -d
   cd ../traefik && docker compose up -d
   ```

## Configuración DNS

El script automático configura:
- Elimina registros A existentes para `*.dominio`
- Crea CNAME `*.dominio` → `<tunnel-id>.cfargotunnel.com`
- Configura Public Hostname en el túnel

Si lo haces manualmente:
1. En Cloudflare DNS: CNAME `*` → `<tunnel-id>.cfargotunnel.com` (Proxy activado)
2. En Zero Trust > Tunnels > [Tu Túnel] > Configure: Añadir Public Hostname `*.dominio` → `https://traefik:443`

## SSL/TLS

- **Cloudflare → Cliente**: Certificado de Cloudflare (automático)
- **Cloudflare → Túnel**: Cifrado del túnel (automático)
- **Túnel → Traefik**: HTTPS interno (certificado wildcard `*.dominio`)
- **Traefik → Servicios**: HTTP interno (red Docker)

Cloudflare maneja los certificados externos. Traefik puede obtener certificados Let's Encrypt para validación interna si es necesario.

## Red Docker

Ambos servicios usan la red `entry`:
- `cloudflared` se conecta a `traefik:443` por nombre de servicio
- Los servicios expuestos también están en `entry`
- Red creada en `services/docker-compose.yml`

## Añadir Servicios

### Opción 1: Configuración Estática (Recomendado)

Crear archivo en `services/traefik/config/dynamic/servicio.yml`:

```yaml
http:
  routers:
    servicio:
      rule: "Host(`servicio.dominio.com`)"
      entryPoints:
        - websecure
      service: servicio
      tls:
        certResolver: cloudflare

  services:
    servicio:
      loadBalancer:
        servers:
          - url: "http://servicio:80"
```

### Opción 2: Labels Docker (si el provider funciona)

En `docker-compose.yml` del servicio:
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.servicio.rule=Host(`servicio.dominio.com`)"
  - "traefik.http.routers.servicio.entrypoints=websecure"
  - "traefik.http.routers.servicio.tls.certresolver=cloudflare"
  - "traefik.http.services.servicio.loadbalancer.server.port=80"
```

## Troubleshooting

**Túnel no conecta**:
```bash
docker logs cloudflared
# Verificar TUNNEL_TOKEN en .env
```

**404 en servicios**:
- Verificar que el servicio está en la red `entry`
- Verificar configuración en `config/dynamic/`
- Verificar logs: `docker logs traefik`

**DNS no resuelve**:
- Verificar CNAME en Cloudflare DNS
- Esperar 1-2 minutos para propagación
- Verificar Public Hostname en Zero Trust

**Certificado SSL**:
- Cloudflare debe estar en modo "Full (Strict)"
- Verificar en: Dashboard > Dominio > SSL/TLS > Overview

## Referencias

- [Cloudflare Tunnel Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Traefik Docs](https://doc.traefik.io/traefik/)

