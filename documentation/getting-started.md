# Inicio Rápido

Guía paso a paso para iniciar todo el proyecto desde cero.

## Requisitos Previos

- Sistema operativo Linux (Ubuntu/Debian recomendado)
- Acceso root o sudo
- Dominio configurado en Cloudflare
- Cuenta de Cloudflare con Zero Trust habilitado

## Pasos de Configuración

### 1. Clonar/Preparar el Proyecto

```bash
cd /ruta/al/proyecto
```

### 2. Crear Archivo de Configuración

Copia el archivo de ejemplo y edítalo con tus valores:

```bash
cp env.example .env
nano .env  # o usa tu editor preferido
```

Configura al menos estas variables básicas iniciales:
- `MAIN_DOMAIN`: Tu dominio principal
- `TZ`: Zona horaria

**Nota**: Las demás variables (Cloudflare, Traefik, etc.) se configurarán en los siguientes pasos o puedes consultar [Variables de Entorno](environment-variables.md) para ver todas las opciones disponibles.

### 3. Instalar Docker

Ejecuta el script de instalación de Docker:

```bash
cd scripts
./10-install-docker.sh
```

**Importante**: Después de la instalación, cierra sesión y vuelve a iniciar sesión (o ejecuta `newgrp docker`) para usar Docker sin `sudo`.

Verifica la instalación:

```bash
docker --version
docker compose version
```

### 4. Configurar Cloudflare Tunnel

Antes de ejecutar el script, necesitas:

1. **Crear un túnel en Cloudflare**:
   - Ve a: Zero Trust > Networks > Tunnels
   - Click en "Create tunnel"
   - Selecciona "Cloudflared" y copia el `TUNNEL_TOKEN`

2. **Obtener API Key de Cloudflare**:
   - Ve a: Profile > API Tokens > Global API Key
   - Copia la API Key

3. **Ejecutar el script de configuración**:

```bash
cd scripts
./20-setup-cloudflare-tunnel.sh
```

El script te pedirá:
- Tu dominio (`MAIN_DOMAIN`)
- Email de Cloudflare (`CF_API_EMAIL`)
- API Key de Cloudflare (`CF_API_KEY`)
- Token del túnel (`CLOUDFLARE_TUNNEL_TOKEN`)
- Email para certificados (`ACME_EMAIL`)

**Nota**: Si alguna variable ya está en tu `.env`, el script la usará automáticamente.

El script automáticamente:
- Configura el archivo `config.yml` de cloudflared
- Configura los registros DNS en Cloudflare
- Configura el Public Hostname en el túnel
- **Inicia primero Cloudflared y luego Traefik**

### 5. Generar Credenciales de Traefik (Opcional)

Para proteger el dashboard de Traefik con autenticación básica, genera las credenciales:

```bash
cd scripts
./30-generate-traefik-auth.sh <usuario> <contraseña>
# Ejemplo: ./30-generate-traefik-auth.sh admin miPassword123
```

El script mostrará una línea como:
```
TRAEFIK_BASIC_AUTH=admin:$apr1$...
```

**Copia esta línea** y añádela a tu archivo `.env` en la raíz del proyecto:

```bash
cd ..
nano .env
# Pega la línea TRAEFIK_BASIC_AUTH=...
```

Luego reinicia Traefik para aplicar los cambios:

```bash
cd services/traefik
docker compose restart
```

**Nota**: Este paso es opcional. Si no configuras autenticación, el dashboard seguirá funcionando pero sin protección (solo accesible localmente en el puerto 8080).

### 6. Verificar que Todo Funciona

Espera 1-2 minutos para que los DNS se propaguen, luego verifica:

```bash
# Ver logs de los servicios
docker logs cloudflared
docker logs traefik

# Probar acceso (si tienes un servicio de prueba configurado)
curl https://whoami.${MAIN_DOMAIN}
```

## Orden de Inicio de Servicios

El orden correcto es:

1. **Cloudflared** (túnel de Cloudflare) - debe iniciarse primero
2. **Traefik** (reverse proxy) - se conecta al túnel

Este orden es importante porque:
- Cloudflared necesita estar listo para recibir tráfico de Cloudflare
- Traefik se conecta a través del túnel, por lo que el túnel debe estar activo primero

## Iniciar Servicios Manualmente

Si necesitas iniciar los servicios manualmente (sin usar el script):

```bash
cd services

# Crear red Docker si no existe
docker network inspect entry >/dev/null 2>&1 || docker network create entry

# Iniciar Cloudflared primero
cd cloudflared
docker compose up -d

# Luego iniciar Traefik
cd ../traefik
docker compose up -d
```

## Detener Servicios

```bash
cd services/traefik
docker compose down

cd ../cloudflared
docker compose down
```

## Reiniciar Servicios

```bash
cd services/cloudflared
docker compose restart

cd ../traefik
docker compose restart
```

## Troubleshooting

### Docker no está disponible

Si después de instalar Docker recibes "permission denied":
```bash
# Cierra sesión y vuelve a iniciar sesión, o:
newgrp docker
```

### El túnel no conecta

```bash
# Verificar logs
docker logs cloudflared

# Verificar que el token está correcto en .env
grep CLOUDFLARE_TUNNEL_TOKEN .env
```

### Traefik no inicia

```bash
# Verificar logs
docker logs traefik

# Verificar que la red 'entry' existe
docker network ls | grep entry
```

### DNS no resuelve

- Espera 1-2 minutos para la propagación DNS
- Verifica en Cloudflare DNS que existe el CNAME `*` → `<tunnel-id>.cfargotunnel.com`
- Verifica en Zero Trust > Tunnels que el Public Hostname está configurado

## Próximos Pasos

Una vez que la infraestructura base esté funcionando:

1. Consulta [Infraestructura de Entrada](infrastructure.md) para entender cómo funciona
2. Revisa [Servicios](services.md) para añadir nuevos servicios

## Referencias

- [Documentación de Infraestructura](infrastructure.md)
- [Estructura de Directorios](directory-structure.md)
- [Scripts de Configuración](../scripts/README.md)

