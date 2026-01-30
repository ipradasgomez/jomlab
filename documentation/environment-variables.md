# Variables de Entorno

Documentación completa de todas las variables de entorno utilizadas en el proyecto.

## Ubicación

Todas las variables se definen en el archivo `.env` en la raíz del proyecto. Copia `env.example` a `.env` y configura los valores según tus necesidades.

## Variables por Categoría

### Configuración General

#### `MAIN_DOMAIN`
- **Descripción**: Dominio principal del homelab
- **Ejemplo**: `tudominio.com`
- **Uso**: Se usa para configurar DNS, certificados SSL y rutas de servicios
- **Requerido**: Sí

#### `TZ`
- **Descripción**: Zona horaria del sistema
- **Ejemplo**: `Europe/Madrid`, `America/New_York`, `UTC`
- **Uso**: Configura la zona horaria en todos los contenedores Docker
- **Requerido**: No (por defecto: `UTC`)

---

### Cloudflare Tunnel

#### `CLOUDFLARE_TUNNEL_TOKEN`
- **Descripción**: Token de autenticación del túnel de Cloudflare
- **Ejemplo**: `eyJhIjoi...` (token largo codificado en base64)
- **Uso**: Autentica el cliente cloudflared con Cloudflare
- **Requerido**: Sí (para usar el túnel)
- **Cómo obtener**: Zero Trust > Networks > Tunnels > Create tunnel > Copiar token

---

### Cloudflare API (para ACME DNS Challenge)

Estas variables se usan para que Traefik pueda obtener certificados SSL mediante el desafío DNS de Cloudflare.

#### `CF_API_EMAIL`
- **Descripción**: Email de tu cuenta de Cloudflare
- **Ejemplo**: `tu@email.com`
- **Uso**: Autenticación con la API de Cloudflare para DNS challenge
- **Requerido**: Sí (si usas certificados Let's Encrypt con Cloudflare)
- **Cómo obtener**: Es el email con el que te registraste en Cloudflare

#### `CF_API_KEY`
- **Descripción**: Global API Key de Cloudflare
- **Ejemplo**: `1234567890abcdef...`
- **Uso**: Autenticación con la API de Cloudflare para DNS challenge
- **Requerido**: Sí (si usas certificados Let's Encrypt con Cloudflare)
- **Cómo obtener**: Profile > API Tokens > Global API Key > View

#### `CF_DNS_API_TOKEN`
- **Descripción**: API Token específico para DNS (alternativa a API Key)
- **Ejemplo**: `token_1234567890abcdef...`
- **Uso**: Alternativa más segura a `CF_API_KEY` (permisos limitados solo a DNS)
- **Requerido**: No (puedes usar `CF_API_KEY` en su lugar)
- **Cómo obtener**: Profile > API Tokens > Create Token > Permisos: Zone DNS Edit

**Nota**: Puedes usar `CF_API_KEY` o `CF_DNS_API_TOKEN`, no necesitas ambos. El token es más seguro porque tiene permisos limitados.

---

### ACME / Let's Encrypt

#### `ACME_EMAIL`
- **Descripción**: Email para notificaciones de Let's Encrypt
- **Ejemplo**: `tu@email.com`
- **Uso**: Let's Encrypt envía notificaciones de expiración de certificados a este email
- **Requerido**: Sí (si usas certificados Let's Encrypt)
- **Nota**: Puede ser el mismo que `CF_API_EMAIL` o diferente

---

### Traefik

#### `TRAEFIK_LOG_LEVEL`
- **Descripción**: Nivel de logging de Traefik
- **Valores posibles**: `DEBUG`, `INFO`, `WARN`, `ERROR`
- **Por defecto**: `INFO`
- **Uso**: Controla la verbosidad de los logs de Traefik
- **Requerido**: No

#### `TRAEFIK_HTTP_PORT`
- **Descripción**: Puerto HTTP de Traefik
- **Por defecto**: `80`
- **Uso**: Puerto donde Traefik escucha tráfico HTTP
- **Requerido**: No
- **Nota**: Normalmente no se expone públicamente (solo HTTPS)

#### `TRAEFIK_HTTPS_PORT`
- **Descripción**: Puerto HTTPS de Traefik
- **Por defecto**: `443`
- **Uso**: Puerto donde Traefik escucha tráfico HTTPS
- **Requerido**: No

#### `TRAEFIK_DASHBOARD_ENABLED`
- **Descripción**: Habilita el dashboard web de Traefik
- **Valores posibles**: `true`, `false`
- **Por defecto**: `true`
- **Uso**: Activa/desactiva el dashboard en `http://localhost:8080`
- **Requerido**: No

#### `TRAEFIK_API_INSECURE`
- **Descripción**: Permite acceso al dashboard sin autenticación
- **Valores posibles**: `true`, `false`
- **Por defecto**: `false`
- **Uso**: Si es `true`, el dashboard es accesible sin autenticación (solo localmente en puerto 8080)
- **Requerido**: No
- **Seguridad**: Mantener en `false` y usar autenticación básica

#### `TRAEFIK_BASIC_AUTH`
- **Descripción**: Credenciales de autenticación básica para el dashboard
- **Formato**: `usuario:hash_password` (múltiples usuarios separados por comas)
- **Ejemplo**: `admin:$apr1$hashed_password_here`
- **Uso**: Protege el dashboard de Traefik con autenticación básica HTTP
- **Requerido**: Sí (si quieres proteger el dashboard)
- **Cómo generar**: Usa el script `scripts/30-generate-traefik-auth.sh <usuario> <contraseña>`

---

### AdGuard Home

Todas las variables de AdGuard Home tienen valores por defecto y son opcionales.

#### `ADGUARD_DNS_IP`
- **Descripción**: IP donde AdGuard Home escucha DNS
- **Por defecto**: `192.168.0.100`
- **Uso**: IP de la interfaz de red donde se expone el servicio DNS
- **Requerido**: No

#### `ADGUARD_HTTP_PORT`
- **Descripción**: Puerto HTTP para la interfaz web de AdGuard Home
- **Por defecto**: `8050`
- **Uso**: Puerto para acceder a la interfaz web (HTTP)
- **Requerido**: No

#### `ADGUARD_HTTPS_PORT`
- **Descripción**: Puerto HTTPS para la interfaz web de AdGuard Home
- **Por defecto**: `4430`
- **Uso**: Puerto para acceder a la interfaz web (HTTPS)
- **Requerido**: No

#### `ADGUARD_ADMIN_PORT`
- **Descripción**: Puerto del panel de administración
- **Por defecto**: `3000`
- **Uso**: Puerto interno del panel de administración
- **Requerido**: No

#### `ADGUARD_DOT_PORT`
- **Descripción**: Puerto para DNS-over-TLS
- **Por defecto**: `853`
- **Uso**: Puerto para conexiones DNS cifradas con TLS
- **Requerido**: No

#### `ADGUARD_DOH_PORT`
- **Descripción**: Puerto para DNS-over-HTTPS
- **Por defecto**: `784`
- **Uso**: Puerto para conexiones DNS cifradas con HTTPS
- **Requerido**: No

#### `ADGUARD_QUIC_PORT`
- **Descripción**: Puerto para DNS-over-QUIC
- **Por defecto**: `8853`
- **Uso**: Puerto para conexiones DNS cifradas con QUIC
- **Requerido**: No

#### `ADGUARD_TLS_PORT`
- **Descripción**: Puerto TLS adicional
- **Por defecto**: `5443`
- **Uso**: Puerto TLS adicional para AdGuard Home
- **Requerido**: No

#### `ADGUARD_DHCP_SERVER_PORT`
- **Descripción**: Puerto del servidor DHCP
- **Por defecto**: `67`
- **Uso**: Puerto donde AdGuard Home escucha peticiones DHCP (si está habilitado)
- **Requerido**: No

#### `ADGUARD_DHCP_CLIENT_PORT`
- **Descripción**: Puerto del cliente DHCP
- **Por defecto**: `68`
- **Uso**: Puerto del cliente DHCP
- **Requerido**: No

---

### FreshRSS

FreshRSS es un lector de feeds RSS/Atom autoalojado. Utiliza la base de datos PostgreSQL compartida.

#### `FRESHRSS_BASE_URL`
- **Descripción**: URL completa donde se accede a FreshRSS
- **Ejemplo**: `https://rss.tekkisma.es`
- **Uso**: Configura la URL base del servicio
- **Requerido**: Sí

#### `FRESHRSS_CRON_MIN`
- **Descripción**: Minutos del cron para actualización automática de feeds
- **Valores posibles**: 
  - `*/20` - Cada 20 minutos (recomendado)
  - `3,33` - A los 3 y 33 minutos de cada hora (cada 30 min)
  - `7` - A los 7 minutos de cada hora (cada hora)
  - Cualquier expresión cron válida para minutos
- **Por defecto**: `*/20`
- **Uso**: Controla la frecuencia de actualización de feeds RSS
- **Requerido**: No (si no se especifica, se actualiza cada 20 minutos)

#### `FRESHRSS_DEFAULT_USER`
- **Descripción**: Nombre del usuario administrador principal
- **Ejemplo**: `admin`
- **Por defecto**: `admin`
- **Uso**: Usuario creado automáticamente durante la instalación
- **Requerido**: Sí

#### `FRESHRSS_ADMIN_EMAIL`
- **Descripción**: Email del usuario administrador
- **Ejemplo**: `tu@email.com`
- **Uso**: Email asociado a la cuenta de administrador
- **Requerido**: Sí

#### `FRESHRSS_ADMIN_PASSWORD`
- **Descripción**: Contraseña del usuario administrador
- **Ejemplo**: Contraseña segura (mínimo 8 caracteres)
- **Uso**: Contraseña para acceder al panel web de FreshRSS
- **Requerido**: Sí
- **Seguridad**: Usa una contraseña fuerte y única

#### `FRESHRSS_ADMIN_API_PASSWORD`
- **Descripción**: Contraseña API para apps móviles
- **Ejemplo**: Contraseña segura diferente a la principal
- **Uso**: Contraseña específica para autenticación desde apps móviles (Google Reader API)
- **Requerido**: Sí (si usas apps móviles)
- **Seguridad**: Debe ser diferente a `FRESHRSS_ADMIN_PASSWORD`
- **Nota**: Configura en apps móviles junto con `FRESHRSS_BASE_URL` y `FRESHRSS_DEFAULT_USER`

#### `FRESHRSS_PG_DB`
- **Descripción**: Nombre de la base de datos en PostgreSQL
- **Ejemplo**: `freshrss`
- **Por defecto**: `freshrss`
- **Uso**: Base de datos que se crea automáticamente en el PostgreSQL compartido
- **Requerido**: No (usa el valor por defecto si no se especifica)
- **Nota**: El usuario `postgres` tiene permisos para crear esta base de datos automáticamente

---

### Storage Services (PostgreSQL y Redis)

PostgreSQL y Redis son servicios compartidos que otros servicios pueden utilizar.

#### `POSTGRES_USER`
- **Descripción**: Usuario de PostgreSQL
- **Ejemplo**: `postgres`
- **Por defecto**: `postgres`
- **Uso**: Usuario con permisos de superusuario en PostgreSQL
- **Requerido**: Sí
- **Nota**: Este usuario tiene permisos para crear bases de datos automáticamente

#### `POSTGRES_PASSWORD`
- **Descripción**: Contraseña del usuario de PostgreSQL
- **Ejemplo**: Generar con `openssl rand -base64 36`
- **Uso**: Contraseña para conectarse a PostgreSQL
- **Requerido**: Sí
- **Seguridad**: Usa una contraseña fuerte generada aleatoriamente

#### `POSTGRES_DB`
- **Descripción**: Base de datos principal de PostgreSQL
- **Ejemplo**: `shared`
- **Por defecto**: `shared`
- **Uso**: Base de datos principal (otros servicios pueden crear sus propias bases de datos)
- **Requerido**: No

#### `REDIS_PASSWORD`
- **Descripción**: Contraseña de Redis
- **Ejemplo**: Generar con `openssl rand -base64 36`
- **Uso**: Contraseña para conectarse a Redis
- **Requerido**: Sí
- **Seguridad**: Usa una contraseña fuerte generada aleatoriamente

#### MinIO

- `MINIO_ROOT_USER`: Usuario admin (default: `admin`)
- `MINIO_ROOT_PASSWORD`: Contraseña (generar con `openssl rand -base64 36`)
- `MINIO_BROWSER`: Habilitar interfaz web (`on`/`off`)
- `MINIO_DOMAIN`: Dominio para buckets (ej: `s3.tekkisma.es`)

---

### Authentik

Authentik es el sistema de autenticación SSO utilizado en el homelab.

#### `AUTHENTIK_SECRET_KEY`
- **Descripción**: Clave secreta para Authentik
- **Ejemplo**: Generar con `openssl rand -base64 60`
- **Uso**: Clave secreta para cifrado y sesiones en Authentik
- **Requerido**: Sí
- **Seguridad**: Debe ser una cadena aleatoria de al menos 50 caracteres

#### `AUTHENTIK_PG_DB`
- **Descripción**: Nombre de la base de datos de Authentik en PostgreSQL
- **Ejemplo**: `authentik`
- **Por defecto**: `authentik`
- **Uso**: Base de datos creada automáticamente en PostgreSQL compartido
- **Requerido**: No (usa el valor por defecto)

#### Variables de Email (Opcional)

Si quieres que Authentik envíe emails (recuperación de contraseña, notificaciones):

- `AUTHENTIK_EMAIL__HOST`: Servidor SMTP (ej: `smtp.gmail.com`)
- `AUTHENTIK_EMAIL__FROM`: Email remitente (ej: `authentik@tudominio.com`)
- `AUTHENTIK_EMAIL__USERNAME`: Usuario SMTP
- `AUTHENTIK_EMAIL__PASSWORD`: Contraseña SMTP
- `AUTHENTIK_EMAIL__USE_TLS`: `true` para TLS
- `AUTHENTIK_EMAIL__USE_SSL`: `false` para TLS
- `AUTHENTIK_EMAIL__PORT`: Puerto SMTP (ej: `587` para TLS, `465` para SSL)

---

### SplitPro

Gestión de gastos compartidos.

#### Variables Básicas (Requeridas)
- `SPLITPRO_BASE_URL`: URL completa (ej: `https://split.tekkisma.es`)
- `SPLITPRO_PG_DB`: Base de datos PostgreSQL (default: `splitpro`)
- `SPLITPRO_NEXTAUTH_SECRET`: Secret key (generar con `openssl rand -base64 32`)

#### Storage S3 (Requerido para recibos)
- `SPLITPRO_R2_ACCESS_KEY`, `SPLITPRO_R2_SECRET_KEY`, `SPLITPRO_R2_BUCKET`
- `SPLITPRO_R2_URL`: Endpoint S3 (ej: `http://storage-minio:9000`)
- `SPLITPRO_R2_PUBLIC_URL`: URL pública (ej: `https://s3.tudominio.com/splitpro`)

#### OAuth (Requerido - al menos uno)
- Google: `SPLITPRO_GOOGLE_CLIENT_ID`, `SPLITPRO_GOOGLE_CLIENT_SECRET`
- O Authentik: `SPLITPRO_AUTHENTIK_ID`, `SPLITPRO_AUTHENTIK_SECRET`, `SPLITPRO_AUTHENTIK_ISSUER`

#### Opcionales
- `SPLITPRO_DEFAULT_HOMEPAGE`, `SPLITPRO_ENABLE_INVITES`, `SPLITPRO_CURRENCY_PROVIDER`
- Email SMTP, Web Push, cache settings

**Ver `VARIABLES_SPLITPRO_MINIO.env` para configuración completa**

---

## Orden de Configuración Recomendado

1. **Variables básicas** (mínimo para empezar):
   - `MAIN_DOMAIN`
   - `TZ`

2. **Variables de Cloudflare** (para el túnel):
   - `CLOUDFLARE_TUNNEL_TOKEN`
   - `CF_API_EMAIL`
   - `CF_API_KEY` (o `CF_DNS_API_TOKEN`)

3. **Variables de certificados**:
   - `ACME_EMAIL`

4. **Variables de Traefik** (después de generar credenciales):
   - `TRAEFIK_BASIC_AUTH` (generar con el script)

5. **Variables de almacenamiento compartido**:
   - `POSTGRES_USER`, `POSTGRES_PASSWORD` (generar con `openssl rand -base64 36`)
   - `REDIS_PASSWORD` (generar con `openssl rand -base64 36`)
   - `MINIO_ROOT_USER`, `MINIO_ROOT_PASSWORD` (si usas MinIO)

6. **Variables de Authentik** (si usas SSO):
   - `AUTHENTIK_SECRET_KEY` (generar con `openssl rand -base64 60`)
   - `AUTHENTIK_PG_DB`

7. **Variables de servicios**:
   - SplitPro, FreshRSS, AdGuard Home, etc.

---

## Ejemplo de `.env` Mínimo

```bash
# Configuración básica
MAIN_DOMAIN=tudominio.com
TZ=Europe/Madrid

# Cloudflare Tunnel
CLOUDFLARE_TUNNEL_TOKEN=tu_token_aqui
CF_API_EMAIL=tu@email.com
CF_API_KEY=tu_api_key_aqui

# ACME
ACME_EMAIL=tu@email.com

# Traefik (generar con script)
TRAEFIK_BASIC_AUTH=admin:$apr1$hashed_password
```

---

## Seguridad

- **Nunca** subas el archivo `.env` a un repositorio público
- El archivo `.env` está en `.gitignore` por defecto
- Usa `CF_DNS_API_TOKEN` en lugar de `CF_API_KEY` si es posible (permisos limitados)
- Mantén `TRAEFIK_API_INSECURE=false` en producción
- Genera contraseñas seguras para `TRAEFIK_BASIC_AUTH`

---

## Referencias

- [Inicio Rápido](getting-started.md) - Guía de configuración inicial
- [Infraestructura de Entrada](infrastructure.md) - Más detalles sobre Cloudflare y Traefik
- [Scripts de Configuración](../scripts/README.md) - Scripts que usan estas variables

