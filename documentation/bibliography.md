# Bibliografía

Referencias y recursos utilizados en la configuración del homelab.

## Cloudflare Tunnel

### Traefik con Cloudflare Tunnels
- **Título**: Using Traefik with Cloudflare Tunnels
- **Autor**: Matt Dyson
- **Fecha**: Febrero 2024
- **URL**: https://mattdyson.org/blog/2024/02/using-traefik-with-cloudflare-tunnels/
- **Descripción**: Guía sobre cómo configurar Traefik para trabajar con túneles de Cloudflare.

### Homelab usando Cloudflared
- **Título**: Homelab using Cloudflared
- **Autor**: Yash Agarwal
- **URL**: https://www.yashagarwal.in/notes/homelab-using-cloudflared
- **Descripción**: Notas y configuración de un homelab utilizando Cloudflared para exposición segura de servicios.

### Tutorial de Cloudflared con Docker Compose
- **Título**: Cloudflared Docker Compose Tutorial
- **Autor**: Sakowi
- **URL**: https://www.sakowi.cz/blog/cloudflared-docker-compose-tutorial/
- **Descripción**: Tutorial paso a paso sobre cómo configurar Cloudflared usando Docker Compose.

## Recursos Adicionales

### Documentación Oficial

#### Cloudflare
- **Cloudflare Tunnel Docs**: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/
- **Cloudflare Zero Trust**: https://developers.cloudflare.com/cloudflare-one/

#### Traefik
- **Traefik Documentation**: https://doc.traefik.io/traefik/
- **Traefik Docker Provider**: https://doc.traefik.io/traefik/providers/docker/

### Herramientas y Utilidades
- **Docker Compose**: https://docs.docker.com/compose/
- **Let's Encrypt**: https://letsencrypt.org/

## AdGuard Home

### Documentación Oficial

#### Preguntas Frecuentes
- **FAQ de AdGuard Home**: https://adguard-dns.io/kb/es/adguard-home/faq/
  - **Descripción**: Documentación oficial con preguntas frecuentes sobre AdGuard Home. Incluye información sobre problemas comunes como "bind: address already in use" relacionados con el DNS stub listener de systemd-resolved en Linux, configuración de reverse proxy, troubleshooting y más.

## Authentik

### Documentación Oficial

#### Instalación y Configuración
- **Docker Compose Installation**: https://docs.goauthentik.io/install-config/install/docker-compose/
  - **Descripción**: Guía oficial para instalar Authentik usando Docker Compose. Incluye requisitos, preparación, configuración de email y puertos personalizados.

- **Reverse Proxy Configuration**: https://docs.goauthentik.io/install-config/reverse-proxy/
  - **Descripción**: Documentación sobre cómo configurar Authentik detrás de un reverse proxy, incluyendo headers requeridos y configuración de WebSockets.

#### Integración con Traefik
- **Traefik Forward Authentication**: https://docs.goauthentik.io/add-secure-apps/providers/proxy/server_traefik/
  - **Descripción**: Guía completa para configurar Authentik como proveedor de autenticación forward con Traefik. Incluye ejemplos para configuración standalone, Docker Compose e Ingress.

### Guías y Tutoriales

#### Authentik Docker Compose Guide 2025
- **Título**: Authentik Docker Compose Guide 2025
- **Autor**: Simple Home Lab
- **Fecha**: 2025
- **URL**: https://www.simplehomelab.com/authentik-docker-compose-guide-2025/
  - **Descripción**: Guía completa y actualizada sobre cómo configurar Authentik con Docker Compose y Traefik. Incluye mejores prácticas, configuración paso a paso y troubleshooting.

#### Authentik behind Traefik (GitHub)
- **Título**: Authentik behind Traefik
- **Autor**: brokenscripts
- **Repositorio**: https://github.com/brokenscripts/authentik_traefik
- **Rama**: traefik3 (Traefik 3.x y Authentik 2024.x)
- **URL**: https://github.com/brokenscripts/authentik_traefik?tab=readme-ov-file
  - **Descripción**: Guía completa para configurar Authentik con Traefik 3.x. Incluye configuración de aplicaciones individuales y dominio completo (catch-all), uso del outpost embebido, configuración de middlewares en Traefik, y ejemplos de Docker Compose. Cubre tanto configuración manual como usando el Wizard de Authentik.

---

## Notas

Este documento se actualiza periódicamente con nuevas referencias y recursos útiles para el mantenimiento y mejora del homelab.
