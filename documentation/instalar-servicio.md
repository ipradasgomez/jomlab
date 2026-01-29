# Resumen: Cómo instalar un servicio en el homelab

Guía rápida de los pasos a seguir cuando se pide instalar un nuevo servicio, según las reglas del proyecto y la documentación existente.

---

## 1. Dónde va cada cosa

| Qué | Dónde |
|-----|--------|
| **Variables de entorno** | Raíz: `.env` (no versionado). Plantilla: `env.example`. Los compose usan `env_file: - ./.env` desde `services/` (el `.env` se copia o enlaza en `services/`). |
| **Compose del servicio** | `services/<servicio>.yml` (en la raíz de `services/`, no dentro de una subcarpeta). |
| **Config propia del servicio** | `services/<servicio>/` (carpeta con configs, ej. `config/`, `config.yml`). |
| **Datos persistentes** | `data/<servicio>/` (nunca dentro de `services/`). |
| **Reglas de Traefik** | `services/traefik/config/dynamic/<servicio>.yml` (routing, TLS, middlewares). **No** en labels del docker-compose. |

---

## 2. Checklist al instalar un servicio

### 2.1 Variables de entorno
- Añadir las variables que necesite el servicio en **`env.example`** (con valores de ejemplo o placeholders).
- Documentar en **`documentation/environment-variables.md`** (nombre, descripción, si es requerida, cómo obtenerla).
- El usuario configura su **`.env`** en la raíz; si los compose cargan desde `services/.env`, asegurarse de que exista (copia o enlace desde la raíz).

### 2.2 Compose del servicio
- Crear **`services/<servicio>.yml`** (nombre en minúsculas, guiones si aplica).
- Incluir siempre:
  - **`env_file: - ./.env`** (ruta relativa al ejecutar desde `services/`).
  - **Red**: `entry` si se expone por Traefik, o la red que corresponda (`apps`, `storage`, etc.). Redes con `external: true`.
- Volúmenes con rutas **relativas a `services/`**:
  - Datos: `../data/<servicio>/<subcarpeta>`.
  - Config local: `./<servicio>/<archivo-o-carpeta>`.
- No poner datos persistentes en `services/`; solo referencias a `../data/<servicio>/`.

### 2.3 Carpeta y ficheros del servicio
- Crear **`services/<servicio>/`** para:
  - Configuración específica (ej. `config/`, `config.yml`, `config.d/`).
  - Opcional: `README.md` del servicio.
- Si el servicio necesita subdominio o HTTPS, no definir el routing en labels; se hace en Traefik (siguiente punto).

### 2.4 Exposición por Traefik (si aplica)
- Crear **`services/traefik/config/dynamic/<servicio>.yml`** con:
  - Router(s) (Host, path, entrypoints, TLS, certResolver).
  - Service (loadBalancer, URL al contenedor, health check si aplica).
  - Middlewares (ej. `authentik-forward-auth`, `error-handler`) si el servicio debe estar protegido o usar la página de error común.
- Regla del proyecto: **todas** las reglas de routing de aplicaciones van en `dynamic/<servicio>.yml`, no en labels del compose.

### 2.5 Datos persistentes
- Crear **`data/<servicio>/`** (y subcarpetas si hace falta, ej. `data/<servicio>/conf`, `data/<servicio>/data`).
- No versionar contenido de `data/` (salvo `.gitkeep` si se quiere mantener la carpeta en git). Datos sensibles ya están en `.gitignore`.

### 2.6 Documentación
- Añadir el servicio en **`documentation/services.md`** (ubicación, función, variables en `.env`, cómo iniciar/parar, acceso, notas).
- Si el servicio tiene pasos de configuración especiales, considerar **`documentation/<servicio>-setup.md`** (como `authentik-setup.md`).

### 2.7 Makefile (opcional)
- Si hay comandos recurrentes, añadir en **`makefiles/infrastructure.mk`** (o el makefile que corresponda) targets tipo `<servicio>-up`, `<servicio>-down`, `<servicio>-logs`, usando `docker compose -f services/<servicio>.yml ...` desde la raíz o desde `services/` según cómo esté definido el resto del Makefile.

---

## 3. Orden práctico al “instalar”

1. Definir variables → `env.example` + `documentation/environment-variables.md`.
2. Crear `services/<servicio>.yml` (red, env_file, volúmenes a `../data/<servicio>/` y `./<servicio>/`).
3. Crear `services/<servicio>/` con la config mínima necesaria.
4. Crear `data/<servicio>/` (y subcarpetas).
5. Si se expone por web: crear `services/traefik/config/dynamic/<servicio>.yml`.
6. Documentar en `documentation/services.md` (y setup específico si hace falta).
7. (Opcional) Añadir targets en el Makefile.

---

## 4. Convenciones a respetar

- **Directorios y archivos**: minúsculas, guiones (`mi-servicio`, `mi-servicio.yml`).
- **Un servicio = un `<servicio>.yml`** en `services/` + su carpeta `services/<servicio>/` + su carpeta `data/<servicio>/`.
- **Config de servicios** en `services/`; **datos** en `data/`; **routing Traefik** en `services/traefik/config/dynamic/`.
- **Rutas relativas** en los compose (desde `services/`: `../data/...`, `./<servicio>/...`).

---

## 5. Referencias en el repo

- Reglas: `rules/directory_organization.md`, `rules/infrastructure_entrypoint.md`.
- Docs: `documentation/directory-structure.md`, `documentation/environment-variables.md`, `documentation/services.md`.
- Ejemplo de servicio con Traefik: `services/whoami.yml` + `services/traefik/config/dynamic/whoami.yml`.
- Ejemplo con config y datos: `services/home-assistant.yml`, `services/home-assistant/config/`, `data/home-assistant/`.
