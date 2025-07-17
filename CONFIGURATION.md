# 🔧 Configuración de PesoTracker

## 📋 Manejo de Datos Sensibles

En Swift/macOS no usamos archivos `.env` como en Node.js. En su lugar, tenemos varias opciones más seguras:

### 1. **Configuración por Ambiente (Recomendado)**

La app usa el archivo `Configuration.swift` que automáticamente detecta el ambiente:

- **Development**: `http://localhost:3000` (para desarrollo local)
- **Staging**: `https://staging-api.pesotracker.com` (para pruebas)
- **Production**: `https://api.pesotracker.com` (para producción)

### 2. **Archivos .xcconfig (Opcional)**

Para configuración más avanzada, puedes usar archivos `.xcconfig`:

1. Copia `Config.xcconfig.example` a `Config.xcconfig`
2. Edita `Config.xcconfig` con tus valores reales
3. El archivo `Config.xcconfig` está en `.gitignore` y no se subirá a GitHub

```bash
# Crear tu archivo de configuración
cp Config.xcconfig.example Config.xcconfig
```

### 3. **Variables de Ambiente en Xcode**

También puedes configurar variables en Xcode:

1. Ve a Product → Scheme → Edit Scheme
2. En la pestaña "Run", ve a "Environment Variables"
3. Agrega tus variables (ej: `API_BASE_URL`)

## 🔒 Seguridad

### ✅ Datos que SÍ van en el código:

- URLs base por ambiente
- Timeouts y configuraciones generales
- Constantes de validación

### ❌ Datos que NO van en el código:

- API Keys secretas
- Passwords
- Certificados privados
- Tokens de terceros

### 🔐 Para datos realmente sensibles:

- Usa el **Keychain** (ya implementado para JWT tokens)
- Variables de ambiente en tiempo de ejecución
- Servicios como AWS Secrets Manager en producción

## 🚀 Configuración Actual

La app está configurada para:

- **Desarrollo**: Conectar a `http://localhost:3000` (tu API local)
- **Producción**: Cambiar automáticamente a HTTPS cuando compiles para release

## 📝 Ejemplo de Uso

```swift
// Usar la configuración
let apiURL = Configuration.API.baseURL
let timeout = Configuration.API.timeout

// O usar las constantes legacy
let url = APIConstants.baseURL
```

## 🔄 Cambiar la URL de la API

Para cambiar la URL de desarrollo, edita `Configuration.swift`:

```swift
case .development:
    return "http://tu-nueva-url:3000"
```
