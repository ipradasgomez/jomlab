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

5. **Variables de servicios** (según necesites):
   - Variables de AdGuard Home (si usas AdGuard Home)

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

