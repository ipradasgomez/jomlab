# Estructura de Directorios

Organización del proyecto homelab. Cada directorio tiene un propósito específico.

## Estructura General

```
jomlab/
├── data/              # Datos persistentes de servicios
├── documentation/     # Documentación del proyecto
├── makefiles/        # Makefiles para comandos comunes
├── rules/            # Reglas para Cursor AI
├── scripts/          # Scripts de gestión (.sh)
├── services/         # Servicios Docker (un directorio por servicio)
├── .env              # Variables de entorno (no versionado)
└── env.example       # Plantilla de variables
```

## Directorios Principales

### `data/`
Datos persistentes de servicios. Cada servicio tiene su subdirectorio.

**Estructura**:
```
data/
├── traefik/
│   └── letsencrypt/     # Certificados SSL
├── adguardhome/
│   ├── work/
│   └── conf/
└── <servicio>/
```

**Reglas**:
- No versionar (excepto `.gitkeep`)
- Datos sensibles en `.gitignore`
- Un subdirectorio por servicio

### `documentation/`
Documentación del proyecto. Este directorio.

**Contenido**:
- `README.md` - Índice
- `infrastructure.md` - Infraestructura de entrada
- `directory-structure.md` - Este archivo
- `services.md` - Documentación de servicios

### `scripts/`
Scripts shell ejecutables para gestión del homelab.

**Ejemplos**:
- `10-install-docker.sh` - Instalación de Docker
- `20-setup-cloudflare-tunnel.sh` - Configuración automática del túnel
- `30-generate-traefik-auth.sh` - Generar autenticación básica

**Reglas**:
- Ejecutables (`chmod +x`)
- Shebang `#!/bin/bash`
- Comentarios descriptivos

### `services/`
Contenedor de todos los servicios Docker.

**Estructura**:
```
services/
├── docker-compose.yml      # Red común 'entry'
├── traefik/
│   ├── docker-compose.yml
│   ├── config/
│   │   ├── traefik.yml
│   │   └── dynamic/
│   └── README.md
├── cloudflared/
│   ├── docker-compose.yml
│   ├── config.yml
│   └── README.md
└── <servicio>/
    ├── docker-compose.yml
    └── <archivos>/
```

**Reglas**:
- Un directorio por servicio
- `docker-compose.yml` en cada servicio
- `env_file: - ../../.env` obligatorio
- Red `entry` externa para servicios expuestos
- Configuración local en el directorio del servicio
- Datos persistentes apuntan a `../../data/<servicio>/`

### `rules/`
Reglas y documentación para Cursor AI. No mover a `documentation/`.

**Contenido**:
- `directory_organization.md` - Reglas de organización
- `infrastructure_entrypoint.md` - Referencia rápida de infraestructura

## Convenciones

### Nomenclatura
- **Directorios**: minúsculas, guiones (`traefik`, `adguard-home`)
- **Archivos**: minúsculas, extensiones apropiadas (`traefik.yml`)
- **Scripts**: minúsculas, guiones, `.sh` (`setup-tunnel.sh`)

### Variables de Entorno
- `.env` en la raíz (no versionado)
- `env.example` como plantilla
- Servicios usan `env_file: - ../../.env`

### Redes Docker
- `entry`: Red de entrada (Traefik, Cloudflared, servicios expuestos)
- Servicios pueden tener redes propias si no necesitan exposición

### Rutas
- Relativas desde el directorio del servicio
- `../../data/<servicio>/` para datos persistentes
- `../../.env` para variables de entorno

## Ejemplo: Añadir un Servicio

1. **Crear directorio**:
   ```bash
   mkdir -p services/mi-servicio
   ```

2. **Crear docker-compose.yml**:
   ```yaml
   version: '3.8'
   services:
     mi-servicio:
       image: mi-imagen:latest
       container_name: mi-servicio
       restart: unless-stopped
       networks:
         - entry
       env_file:
         - ../../.env
       volumes:
         - ../../data/mi-servicio:/data
   networks:
     entry:
       name: entry
       external: true
   ```

3. **Crear directorio de datos**:
   ```bash
   mkdir -p data/mi-servicio
   ```

4. **Configurar en Traefik** (si necesita exposición):
   - Crear `services/traefik/config/dynamic/mi-servicio.yml`
   - O añadir labels al docker-compose.yml

5. **Iniciar**:
   ```bash
   cd services/mi-servicio
   docker compose up -d
   ```

## Notas Importantes

1. **Separación de responsabilidades**:
   - Configuración de servicios → `services/`
   - Datos persistentes → `data/`
   - Scripts de gestión → `scripts/`
   - Documentación → `documentation/`

2. **No mezclar**:
   - No poner datos en `services/`
   - No poner configuración en `data/`
   - No poner scripts de servicios en `scripts/` (van en el servicio)

3. **Portabilidad**:
   - Usar rutas relativas siempre
   - Variables de entorno en `.env`
   - No hardcodear rutas absolutas

