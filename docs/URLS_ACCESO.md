# 🌐 URLs de Acceso - Clínica HIA

Documento que explica las diferentes formas de acceder a la aplicación.

## 📍 URLs Disponibles

### 1. **Usuarios Externos (Internet Pública)** 🌍

**URL:** `https://clinica.clinica-hia.site`

- **Protocolo:** HTTPS (cifrado por Cloudflare)
- **Acceso:** A través de Cloudflare Tunnel
- **Quién:** Pacientes y usuarios externos
- **Ventajas:**
  - Accesible desde cualquier lugar del mundo
  - Certificado SSL automático
  - Protección DDoS de Cloudflare
  - Cifrado end-to-end

---

### 2. **Equipo Interno (Tailscale/VPN)** 🏢

**URL:** `https://clinica.tail9fe3bf.ts.net`

- **Protocolo:** HTTPS
- **Acceso:** Red privada Tailscale
- **Quién:** Equipo de la clínica (médicos, administrativos, TI)
- **Ventajas:**
  - Acceso rápido sin exponerse a internet
  - Conexión privada encriptada
  - Solo miembros de la red Tailscale

---

### 3. **Acceso por IP Tailscale (Fallback)** 🔧

**URL:** `http://100.65.42.112:8083`

- **Protocolo:** HTTP
- **Acceso:** Red privada Tailscale
- **Quién:** Personal técnico
- **Cuándo:** Si los dominios tienen problemas
- **Nota:** Menos seguro, solo para debugging

---

### 4. **Localhost (Desarrollo)** 💻

**URL:** `http://clinica.localhost` o `http://localhost:4200`

- **Protocolo:** HTTP
- **Acceso:** Máquina local
- **Quién:** Desarrolladores
- **Cuándo:** Durante desarrollo local

---

## 🔐 Configuración CORS (Backend)

El backend permite peticiones desde todos estos orígenes:

```javascript
whiteList = [
    'https://clinica.clinica-hia.site',           // Cloudflare Tunnel
    'https://clinica.tail9fe3bf.ts.net',         // Tailscale
    'http://100.65.42.112:8083',                 // IP Tailscale
    'http://clinica.localhost',                  // Localhost
    'http://localhost:4200',                     // Dev Angular
    'http://localhost:3000',                     // Dev alternativo
    'https://www.mercadopago.com.ar',            // MercadoPago
    'https://sandbox.mercadopago.com.ar',        // MercadoPago Sandbox
    undefined                                     // Llamadas sin Origin (curl, server-to-server)
]
```

---

## 🚀 Flujo de Acceso

### Usuario Externo (Web)
```
Internet
    ↓
https://clinica.clinica-hia.site
    ↓ (Cloudflare Tunnel)
cloudflared (host:localhost:8083)
    ↓
Docker Frontend (127.0.0.1:8083)
    ↓ (Peticiones API)
Backend (Puerto 4000)
    ↓
MySQL (Base de datos)
```

### Equipo Interno (Tailscale)
```
Red Tailscale
    ↓
https://clinica.tail9fe3bf.ts.net
    ↓ (Traefik Router)
Docker Frontend
    ↓ (Peticiones API)
Backend (Puerto 4000)
    ↓
MySQL (Base de datos)
```

---

## 📋 Tabla Comparativa

| Aspecto | Internet Pública | Tailscale | Localhost |
|---------|-----------------|-----------|-----------|
| **URL** | `clinica.clinica-hia.site` | `clinica.tail9fe3bf.ts.net` | `localhost:4200` |
| **Protocolo** | HTTPS | HTTPS | HTTP |
| **Quién accede** | Usuarios externos | Equipo interno | Desarrolladores |
| **Firewall** | Cloudflare | Tailscale | Local |
| **SSL/TLS** | Automático | Automático | No |
| **Performance** | Normal | Rápido | Rápido |
| **Público** | ✅ Sí | ❌ No | ❌ No |

---

## 🔧 Troubleshooting

### "Error de CORS" en login
**Causa:** La URL de origen no está en la whitelist

**Soluciones:**
1. Verifica que usas una URL válida de la lista anterior
2. Revisa que el protocolo es correcto (HTTP vs HTTPS)
3. Si usas otro dominio, contácta al equipo TI

---

### No puedo acceder desde Tailscale
**Causa:** Posible problema de conectividad

**Troubleshooting:**
```bash
# Verificar conexión Tailscale
tailscale status

# Probar ping
ping clinica.tail9fe3bf.ts.net

# Verificar disponibilidad
curl https://clinica.tail9fe3bf.ts.net
```

---

### Cloudflare no funciona
**Causa:** Posible problema con cloudflared

**Troubleshooting:**
```bash
# Ver estado del tunnel
sudo journalctl -u cloudflared -n 20

# Verificar conectividad
curl https://clinica.clinica-hia.site
```

---

## 📞 Soporte

Si tienes problemas de acceso:

1. **Verifica la URL correcta** según tu tipo de acceso
2. **Limpia cache y cookies** del navegador
3. **Intenta incógnito** para descartar extensiones
4. **Contácta a TI** si persiste el problema

Proporciona:
- URL que intentabas acceder
- Error específico
- Navegador y sistema operativo
- Si es desde red local o internet

---

**Última actualización:** 28 de noviembre de 2025  
**Estado:** ✅ Todos los orígenes funcionando correctamente
