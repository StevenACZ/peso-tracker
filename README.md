# 📊 PesoTracker

Una aplicación macOS elegante y completa para el seguimiento de peso con características avanzadas.

## ✨ Características Principales

### 🔐 **Autenticación Completa**
- Registro e inicio de sesión seguro con JWT
- Sistema completo de recuperación de contraseña
- Verificación por código de 6 dígitos
- Almacenamiento seguro en Keychain

### ⚖️ **Seguimiento de Peso**
- Registro de peso con fecha personalizable
- Subida de fotos de progreso
- Historial completo con tabla paginada
- Edición y eliminación de registros

### 🎯 **Metas y Objetivos**
- Creación de metas de peso personalizadas
- Seguimiento de progreso hacia objetivos
- Indicadores visuales de avance
- Gestión completa de metas

### 📈 **Análisis y Estadísticas**
- Gráficos interactivos de progreso
- Filtros por rango de tiempo
- Predicciones de peso futuro
- Visualización de tendencias

### 🧮 **Calculadora BMI**
- Cálculo automático del índice de masa corporal
- Clasificaciones médicas con códigos de color
- Rango de peso ideal personalizado
- Entrada de altura, peso, edad y género

### 📷 **Galería de Progreso**
- Visualización de fotos organizadas por fecha
- Navegación intuitiva entre imágenes
- Carga lazy para mejor rendimiento
- Indicadores de progreso visual

### 💾 **Exportación de Datos**
- Exportación completa de datos a CSV
- Descarga organizada de fotos de progreso
- Generación de archivos de metadatos
- Sistema de carpetas estructurado

### ⚡ **Rendimiento Optimizado**
- Sistema de caché inteligente LRU
- Carga instantánea de datos frecuentes
- Invalidación automática de caché
- Gestión eficiente de memoria

## 🛠️ Tecnologías

- **SwiftUI** - Interfaz de usuario moderna y reactiva
- **Combine** - Programación reactiva y manejo de estado
- **JWT** - Autenticación segura basada en tokens
- **Async/Await** - Operaciones asíncronas eficientes
- **Core Data** - Persistencia local inteligente

## 💻 Requisitos del Sistema

- **macOS** 12.0 o superior
- **Xcode** 14.0 o superior para desarrollo
- Resolución mínima: 1000x700 px

## 🚀 Instalación

1. Clona el repositorio
2. Abre `PesoTracker.xcodeproj` en Xcode
3. Ejecuta el proyecto con ⌘+R

```bash
git clone [repository-url]
cd PesoTracker
open PesoTracker.xcodeproj
```

## 🏗️ Arquitectura

**Patrón MVVM** con SwiftUI y Combine:
- **Views**: Componentes de interfaz modulares
- **ViewModels**: Lógica de negocio y gestión de estado
- **Services**: Comunicación con API y servicios core
- **Models**: Estructuras de datos con soporte Codable

## 📁 Estructura del Proyecto

```
PesoTracker/
├── Views/                  # Componentes de UI
│   ├── Auth/              # Flujo de autenticación
│   └── Dashboard/         # Panel principal y modales
├── Services/              # Servicios de negocio
├── ViewModels/            # Lógica de presentación
├── Models/                # Modelos de datos
└── Utils/                 # Utilidades y extensiones
```

## 🎨 Características de Diseño

- **Tema Verde** elegante y profesional
- **Localización** completa en español
- **Animaciones** suaves y naturales
- **Loading States** con esqueletos profesionales
- **Responsive** adaptable a diferentes tamaños

## 📱 Capturas de Pantalla

La aplicación incluye:
- Dashboard principal con sidebar de 35% y contenido de 65%
- Modales elegantes para gestión de peso y metas
- Gráficos interactivos con filtros temporales
- Sistema de configuración avanzada

---

**Creado con amor por Steven** ❤️