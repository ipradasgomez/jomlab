# Configuración de Authentik para Traefik ForwardAuth

Esta guía explica cómo configurar Authentik para proteger servicios con autenticación mediante Traefik.

## Problema

Si al acceder a `https://whoami.tekkisma.es` no te pide autenticación, es porque el **Outpost** de Authentik no tiene **Providers** asignados.

## Solución: Configurar Proxy Provider y Outpost

### ¿Implicit o Explicit Consent?

**Para Traefik forwardAuth, usa siempre IMPLICIT consent:**

- **Implicit Consent** ✅ (Recomendado):
  - El usuario se autentica una vez y puede acceder a los servicios
  - No necesita dar permiso explícito cada vez
  - Perfecto para servicios internos/propios
  - Es lo que necesitas para Traefik forwardAuth

- **Explicit Consent** ❌ (NO usar aquí):
  - El usuario debe dar permiso explícito cada vez que una aplicación quiere acceder
  - Es para OAuth donde aplicaciones externas piden acceso
  - No es necesario para servicios propios protegidos por Traefik

### Paso 1: Crear un Proxy Provider

1. Accede al panel de administración de Authentik:
   ```
   https://auth.tekkisma.es/if/admin/
   ```

2. Ve a **Applications** → **Providers** en el menú lateral

3. Click en **Create** → **Proxy Provider**

4. Configura los siguientes campos:
   - **Name**: `Traefik Proxy` (o el nombre que prefieras)
   - **Authorization flow**: 
     - ✅ **Usa "implicit consent"** (recomendado para Traefik forwardAuth)
     - ❌ **NO uses "explicit consent"** (es para OAuth donde el usuario debe dar permiso explícito)
     - Busca: `default-provider-authorization-implicit-consent` o similar
   - **Tipo de Proxy** (tres opciones):
     - ✅ **"Proxy"** ← **SELECCIONA ESTA** (la primera opción)
       - Traefik hace el proxy, Authentik solo valida autenticación
       - Es la correcta para Traefik forwardAuth
       - ⚠️ **LIMITACIÓN**: NO acepta wildcards (`*`) en External host
     - ❌ **"Autenticación por reenvío (aplicación única)"** - NO usar
       - Authentik maneja el proxy directamente para una sola app
     - ⚠️ **"Autenticación por reenvío (nivel de dominio)"** - Permite wildcards pero cambia el comportamiento
       - Permite usar `https://*.tekkisma.es` 
       - Pero Authentik maneja el proxy a nivel de dominio
       - Solo usar si realmente necesitas wildcards y entiendes las implicaciones
   - **External host**: 
     - ⚠️ **IMPORTANTE**: El tipo "Proxy" NO acepta wildcards (`*`)
     - **Opción A (Recomendada para empezar)**: `https://whoami.tekkisma.es`
       - Usa el dominio específico del servicio
       - Cuando necesites proteger más servicios, crea providers adicionales
     - **Opción B (Si necesitas wildcards)**: Cambia a "Autenticación por reenvío (nivel de dominio)"
       - Permite usar `https://*.tekkisma.es`
       - Pero cambia cómo funciona el proxy (Authentik lo maneja directamente)
   - **Internal host**: 
     - Si usas `https://whoami.tekkisma.es` (recomendado):
       - Usa `http://whoami:80` (URL interna del servicio whoami)
     - Si cambias a "Autenticación por reenvío (nivel de dominio)" con wildcard:
       - Puedes usar `http://traefik:80` o dejar un valor genérico
   - **Internal host SSL Validation**: ❌ **Desactivado** (importante si usas HTTP interno)

5. Click en **Create**

### Paso 2: Crear una Application (Opcional pero recomendado)

1. Ve a **Applications** → **Applications**

2. Click en **Create**

3. Configura:
   - **Name**: `Whoami` (o el nombre del servicio)
   - **Slug**: `whoami` (o el slug que prefieras)
   - **Provider**: Selecciona el Proxy Provider que creaste en el Paso 1
   - **Launch URL**: `https://whoami.tekkisma.es` (opcional)

4. Click en **Create**

### Paso 3: Asignar Provider al Outpost

1. Ve a **Outposts** → **Outposts**

2. Abre el outpost existente (debería haber uno por defecto llamado "authentik Embedded Outpost" o similar)

3. En la sección **Selected Providers** o **Applications**, añade:
   - El **Proxy Provider** que creaste en el Paso 1, O
   - La **Application** que creaste en el Paso 2

4. Verifica que:
   - **Type**: `Proxy`
   - **Service Connection**: Debe estar configurado (generalmente hay uno por defecto)
   - **Configuration**: Debe tener la URL correcta

5. Click en **Update**

### Paso 4: Verificar que el Outpost se actualice

Después de guardar, el outpost debería recargarse automáticamente. Si no funciona:

```bash
docker restart authentik-worker
```

Verifica los logs para confirmar:

```bash
docker logs authentik-worker --tail 20 | grep -i "outpost\|provider"
```

Deberías ver algo como:
```
"event":"Outpost authentik-embedded-outpost started"
```

### Paso 5: Probar la autenticación

1. Abre una ventana de incógnito o cierra sesión en Authentik

2. Accede a: `https://whoami.tekkisma.es`

3. Deberías ser redirigido a la página de login de Authentik

4. Después de autenticarte, deberías ver la página de whoami con información sobre tu sesión

## Configuración para múltiples servicios

Como el tipo "Proxy" NO acepta wildcards, tienes dos opciones:

### Opción 1: Un Provider por servicio (Recomendado)

Crea un **Proxy Provider** separado para cada servicio que quieras proteger:

1. **Para whoami**:
   - External host: `https://whoami.tekkisma.es`
   - Internal host: `http://whoami:80`

2. **Para adguard** (cuando lo necesites):
   - External host: `https://adguard.tekkisma.es`
   - Internal host: `http://adguardhome:80`

3. **Para cada nuevo servicio**:
   - Crea un nuevo Provider con su dominio específico
   - Asigna todos los Providers al mismo Outpost

**Ventajas**:
- Control granular por servicio
- Funciona perfectamente con Traefik forwardAuth
- Puedes tener configuraciones diferentes por servicio

### Opción 2: Usar "Autenticación por reenvío (nivel de dominio)" con wildcard

Si realmente necesitas usar wildcards:

1. Cambia el tipo a **"Autenticación por reenvío (nivel de dominio)"**
2. External host: `https://*.tekkisma.es`
3. Internal host: `http://traefik:80` (o valor genérico)

**⚠️ Consideraciones**:
- Authentik maneja el proxy directamente (no solo la autenticación)
- Puede tener implicaciones en cómo Traefik enruta el tráfico
- Menos control granular por servicio

## Troubleshooting

### El outpost no tiene providers asignados

**Error en logs**: `"No providers assigned to this outpost"`

**Solución**: Sigue el Paso 3 para asignar el provider al outpost.

### Error 404 al acceder a `/outpost.goauthentik.io/auth/traefik`

**Causa**: El outpost no está configurado correctamente o no tiene providers.

**Solución**: 
1. Verifica que el provider esté asignado al outpost
2. Reinicia el worker: `docker restart authentik-worker`
3. Verifica los logs: `docker logs authentik-worker --tail 50`

### No me redirige al login

**Causa**: El middleware de Traefik no está configurado correctamente.

**Solución**: Verifica que en `services/traefik/config/dynamic/whoami.yml` (o el archivo del servicio) tenga:
```yaml
middlewares:
  - authentik-forward-auth
```

### El outpost no se actualiza

**Solución**: 
1. Reinicia el worker: `docker restart authentik-worker`
2. Verifica que el Service Connection esté configurado en el outpost
3. Revisa los logs: `docker logs authentik-worker --tail 100`

## Referencias

- [Documentación oficial de Authentik - Proxy Provider](https://goauthentik.io/docs/providers/proxy/)
- [Documentación oficial de Authentik - Outposts](https://goauthentik.io/docs/outposts/)

