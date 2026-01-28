# Servicios

Documentación de servicios individuales del homelab.

## Servicios de Almacenamiento

### PostgreSQL (Compartido)
Base de datos PostgreSQL compartida para todos los servicios que la requieran.

**Ubicación**: `services/storage-postgresql.yml`

**Función**:
- Base de datos compartida para todos los servicios
- Red `storage` para aislamiento de red

**Configuración**:
- Variables en `.env`:
  - `POSTGRES_USER`: Usuario de la base de datos (default: `postgres`, tiene permisos de superusuario)
  - `POSTGRES_PASSWORD`: Contraseña de la base de datos
  - `POSTGRES_DB`: Base de datos principal (default: `shared`)

**Uso**:
- Los servicios se conectan usando el nombre del contenedor: `storage-postgresql`
- Todos los servicios comparten la misma instancia de PostgreSQL y credenciales
- Cada servicio puede usar su propia base de datos (Authentik y otros servicios la crearán automáticamente)
- O pueden compartir la misma base de datos (`POSTGRES_DB`) usando diferentes esquemas
- El usuario `postgres` tiene permisos para crear bases de datos automáticamente
- Datos persistentes en `data/storage/postgresql/`

**Ver logs**: `docker logs storage-postgresql`

### Redis (Compartido)
Cache y cola de mensajes Redis compartida para todos los servicios que la requieran.

**Ubicación**: `services/storage-redis.yml`

**Función**:
- Cache compartida para múltiples servicios
- Cola de mensajes para tareas asíncronas
- Red `storage` para aislamiento de red

**Configuración**:
- Variables en `.env`:
  - `REDIS_PASSWORD`: Contraseña de Redis (requerida)

**Uso**:
- Los servicios se conectan usando el nombre del contenedor: `storage-redis`
- Cada servicio puede usar diferentes bases de datos Redis (0-15)
- Datos persistentes en `data/storage/redis/`

**Ver logs**: `docker logs storage-redis`

**Nota**: Los servicios de almacenamiento deben iniciarse antes que los servicios que los usan:
```bash
cd services
docker compose -f storage-postgresql.yml up -d
docker compose -f storage-redis.yml up -d
```

## Servicios de Infraestructura

### Traefik
Reverse proxy y load balancer.

**Ubicación**: `services/traefik.yml` (docker-compose) y `services/traefik/` (configuraciones)

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

**Ubicación**: `services/cloudflared.yml` (docker-compose) y `services/cloudflared/` (configuraciones)

**Función**:
- Crear túnel seguro hacia Cloudflare
- Reenviar tráfico a Traefik
- No requiere puertos abiertos

**Configuración**:
- `config.yml`: Reglas de ingress
- Variables: `.env` (TUNNEL_TOKEN)

**Ver logs**: `docker logs cloudflared`

**Documentación**: Ver `services/cloudflared/README.md`

### Authentik
Sistema de autenticación y gestión de identidad (SSO).

**Ubicación**: `services/authentik.yml` (docker-compose) y `services/authentik/` (configuraciones)

**Función**:
- Autenticación centralizada (SSO)
- Gestión de usuarios y grupos
- Integración con Traefik mediante forwardAuth
- Protección de subdominios (no del dominio raíz)

**Configuración**:
- Variables requeridas en `.env`:
  - `AUTHENTIK_SECRET_KEY`: Clave secreta (generar con `openssl rand -base64 60`)
  - `AUTHENTIK_PG_DB`: Nombre de la base de datos (default: `authentik`, debe estar en `POSTGRES_DATABASES`)
  - Usa la misma instancia PostgreSQL: `POSTGRES_USER`, `POSTGRES_PASSWORD`
  - `REDIS_PASSWORD`: Contraseña de Redis (compartida)
- **Requisitos**: Requiere que `storage-postgresql` y `storage-redis` estén corriendo
- Acceso inicial: `https://auth.tekkisma.es/if/flow/initial-setup/`
- Usuario por defecto: `akadmin`

**Autenticación**:
- Se aplica automáticamente a todos los subdominios mediante el middleware `authentik-forward-auth`
- El dominio raíz (`tekkisma.es`) NO requiere autenticación
- Configuración en `traefik/config/dynamic/authentik.yml`

**Ver logs**: `docker logs authentik-server`

**Documentación**: Ver [Bibliografía](bibliography.md#authentik)

## Servicios de Aplicación

### Whoami
Servicio de prueba que muestra información de la petición HTTP.

**Ubicación**: `services/whoami.yml` (docker-compose) y `services/traefik/config/dynamic/whoami.yml` (configuración)

**Uso**: Prueba de conectividad, configuración y autenticación.

**Acceso**: `https://whoami.tekkisma.es`

**Autenticación**: Requiere login mediante Authentik (protegido por `authentik-forward-auth` middleware)

### AdGuard Home
Servidor DNS con bloqueo de anuncios.

**Ubicación**: `services/adguardhome.yml` (docker-compose) y `services/adguardhome/` (configuraciones)

**Puertos**:
- DNS: 53 (TCP/UDP)
- Admin: 3000
- HTTP: 8050
- HTTPS: 4430

**Configuración**: Primera vez accede a `http://localhost:3000`

### Home Assistant
Sistema de automatización del hogar y control de dispositivos IoT.

**Ubicación**: 
- `services/home-assistant.yml` (docker-compose)
- `services/home-assistant/config/` (archivos de configuración YAML versionados)
- `services/traefik/config/dynamic/home-assistant.yml` (configuración de Traefik)

**Función**:
- Automatización del hogar
- Control de dispositivos IoT
- Integración con múltiples plataformas y dispositivos

**Configuración**:
- Variables en `.env`:
  - `TZ`: Zona horaria (default: `UTC`)
- Archivos de configuración en `services/home-assistant/config/`:
  - `configuration.yaml` - Configuración principal
  - `automations.yaml` - Automatizaciones
  - `scripts.yaml` - Scripts
  - `scenes.yaml` - Escenas
  - `secrets.yaml` - Secretos (no versionar en git)
- Datos persistentes (DB, logs, etc.) se generan en `services/home-assistant/config/` pero se ignoran con `.gitignore`
- Primera vez accede a `https://home.tekkisma.es` para el onboarding inicial
- Requiere modo `privileged` para acceso completo a dispositivos del sistema

**Autenticación**: Requiere login mediante Authentik (protegido por `authentik-forward-auth` middleware)

**Acceso**: `https://home.tekkisma.es`

**Notas**:
- El contenedor usa `privileged: true` para acceso completo a dispositivos (necesario para integraciones como Bluetooth, USB, etc.)
- El volumen `/run/dbus` está montado en modo lectura para soporte de Bluetooth
- Después del primer inicio, sigue el proceso de onboarding en la interfaz web

**Ver logs**: `docker logs home-assistant`

## Añadir un Nuevo Servicio

1. Crear directorio en `services/<servicio>/` para configuraciones
2. Crear `<servicio>.yml` en `services/` con:
   - Red `entry` (si necesita exposición)
   - `env_file: - ./.env`
   - Volúmenes a `../data/<servicio>/`
   - Rutas a configuraciones: `./<servicio>/config/`
3. Crear configuración en Traefik si necesita exposición
4. Crear directorio en `data/` si necesita persistencia
5. Documentar en este archivo

## Gestión de Servicios

**Iniciar**:
```bash
cd services
docker compose -f <servicio>.yml up -d
```

**Detener**:
```bash
cd services
docker compose -f <servicio>.yml down
```

**Logs**:
```bash
docker logs <servicio>
# o
cd services
docker compose -f <servicio>.yml logs -f
```

**Reiniciar**:
```bash
cd services
docker compose -f <servicio>.yml restart
```

