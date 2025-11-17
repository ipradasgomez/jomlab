# Configuraciones Dinámicas de Traefik

Este directorio contiene configuraciones dinámicas de Traefik que se recargan automáticamente sin necesidad de reiniciar el servicio.

## Regla Importante

**Todas las reglas de routing de Traefik para aplicaciones deben ir en este directorio** (`services/traefik/config/dynamic/<servicio>.yml`), **NO en labels de docker-compose**.

## Uso

Crea archivos `.yml` en este directorio con tus configuraciones dinámicas. Traefik los detectará y aplicará automáticamente.

## Ejemplos

### Middlewares de Headers de Seguridad

Crea `middlewares.yml`:

```yaml
http:
  middlewares:
    default-headers:
      headers:
        frameDeny: true
        sslRedirect: true
        browserXssFilter: true
        contentTypeNosniff: true
        forceSTSHeader: true
        stsIncludeSubdomains: true
        stsPreload: true
        stsSeconds: 15552000
```

### Rate Limiting

Crea `rate-limit.yml`:

```yaml
http:
  middlewares:
    rate-limit:
      rateLimit:
        average: 100
        burst: 50
```

## Documentación

- [Traefik Dynamic Configuration](https://doc.traefik.io/traefik/v3.0/reference/dynamic-configuration/overview/)

