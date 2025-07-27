# Requirements Document

## Introduction

PesoTracker es una aplicación nativa para macOS que permite a los usuarios rastrear su peso corporal, establecer metas de peso, visualizar su progreso con fotos y obtener predicciones inteligentes sobre cuándo alcanzarán sus objetivos. La aplicación utiliza SwiftUI con arquitectura MVVM, autenticación JWT y una API REST para proporcionar una experiencia moderna y eficiente de seguimiento de peso.

## Requirements

### Requirement 1

**User Story:** Como usuario nuevo, quiero poder registrarme en la aplicación con mi email, nombre de usuario y contraseña, para que pueda comenzar a rastrear mi peso.

#### Acceptance Criteria

1. WHEN el usuario abre la aplicación por primera vez THEN el sistema SHALL mostrar la pantalla de login
2. WHEN el usuario hace clic en "Registrarse" THEN el sistema SHALL mostrar un formulario con campos para username, email y password
3. WHEN el usuario completa todos los campos requeridos y hace clic en "Registrar" THEN el sistema SHALL enviar los datos al endpoint POST /auth/register
4. IF el registro es exitoso THEN el sistema SHALL guardar el token JWT y redirigir al dashboard
5. IF el registro falla THEN el sistema SHALL mostrar un mensaje de error específico

### Requirement 2

**User Story:** Como usuario registrado, quiero poder iniciar sesión con mi email y contraseña, para que pueda acceder a mis datos de peso.

#### Acceptance Criteria

1. WHEN el usuario ingresa email y contraseña válidos THEN el sistema SHALL autenticar al usuario mediante POST /auth/login
2. IF la autenticación es exitosa THEN el sistema SHALL guardar el token JWT en Keychain y mostrar el dashboard
3. IF la autenticación falla THEN el sistema SHALL mostrar un mensaje de error "Credenciales inválidas"
4. WHEN la aplicación se abre y existe un token válido THEN el sistema SHALL redirigir automáticamente al dashboard
5. WHEN el usuario hace clic en "Logout" THEN el sistema SHALL eliminar el token y redirigir al login

### Requirement 3

**User Story:** Como usuario autenticado, quiero ver un dashboard dividido en dos paneles (35/65), para que pueda tener una vista completa de mi progreso de peso.

#### Acceptance Criteria

1. WHEN el usuario accede al dashboard THEN el sistema SHALL mostrar un layout dividido con panel izquierdo (35%) y derecho (65%)
2. WHEN se carga el dashboard THEN el panel izquierdo SHALL mostrar resumen personal, meta principal, milestone activo y botones de acción
3. WHEN se carga el dashboard THEN el panel derecho SHALL mostrar gráfico de progreso y tabla de pesos
4. IF no hay datos de peso THEN el sistema SHALL mostrar mensaje "¡Comencemos! Agrega tu primer peso" y abrir automáticamente el modal de entrada
5. WHEN hay datos disponibles THEN el sistema SHALL mostrar toda la información actualizada en tiempo real

### Requirement 4

**User Story:** Como usuario, quiero poder agregar registros de peso con fecha, notas opcionales y fotos, para que pueda mantener un historial completo de mi progreso.

#### Acceptance Criteria

1. WHEN el usuario hace clic en "+ Agregar Peso" THEN el sistema SHALL abrir un modal con campos para peso, fecha, notas y foto
2. WHEN el usuario completa el peso y fecha THEN el sistema SHALL validar que el peso sea un número positivo
3. WHEN el usuario selecciona una foto THEN el sistema SHALL permitir subir archivos JPG/PNG
4. WHEN el usuario guarda el registro THEN el sistema SHALL enviar los datos al endpoint POST /weights
5. IF el guardado es exitoso THEN el sistema SHALL actualizar la tabla de pesos y cerrar el modal
6. WHEN el usuario hace clic en editar un peso THEN el sistema SHALL abrir el modal con los datos precargados

### Requirement 5

**User Story:** Como usuario, quiero establecer una meta principal de peso con fecha objetivo, para que pueda tener un objetivo claro hacia el cual trabajar.

#### Acceptance Criteria

1. WHEN el usuario hace clic en "+ Nueva Meta" THEN el sistema SHALL abrir un modal para crear una meta principal
2. WHEN el usuario ingresa peso objetivo y fecha THEN el sistema SHALL validar que el peso sea diferente al actual
3. WHEN se guarda una meta THEN el sistema SHALL enviar los datos al endpoint POST /goals con type: "main"
4. IF ya existe una meta principal THEN el sistema SHALL permitir editarla o reemplazarla
5. WHEN existe una meta principal THEN el sistema SHALL mostrar el progreso calculado y predicción de fecha

### Requirement 6

**User Story:** Como usuario, quiero poder crear milestones intermedios hacia mi meta principal, para que pueda tener objetivos más alcanzables a corto plazo.

#### Acceptance Criteria

1. WHEN el usuario hace clic en "+ Milestone" THEN el sistema SHALL abrir un modal con sugerencia automática (25% del camino hacia la meta)
2. WHEN existe un milestone activo THEN el sistema SHALL permitir solo un milestone activo por vez
3. WHEN el usuario completa un milestone THEN el sistema SHALL mostrar modal de celebración "¡Objetivo alcanzado! 🎉"
4. WHEN se completa un milestone THEN el sistema SHALL ofrecer opciones para crear el siguiente o generar automáticamente
5. IF se elimina la meta principal THEN el sistema SHALL eliminar automáticamente todos los milestones relacionados

### Requirement 7

**User Story:** Como usuario, quiero ver predicciones inteligentes de cuándo alcanzaré mis metas, para que pueda planificar mejor mi progreso.

#### Acceptance Criteria

1. WHEN hay al menos 2 registros de peso THEN el sistema SHALL calcular el promedio semanal de pérdida/ganancia
2. WHEN se calcula el promedio THEN el sistema SHALL predecir la fecha estimada para alcanzar la meta
3. WHEN la tendencia es positiva (perdiendo peso hacia la meta) THEN el sistema SHALL mostrar colores verdes
4. WHEN la tendencia es negativa THEN el sistema SHALL mostrar colores rojos
5. WHEN la tendencia es estable THEN el sistema SHALL mostrar colores amarillos

### Requirement 8

**User Story:** Como usuario, quiero ver mi progreso fotográfico en un carrusel navegable, para que pueda visualizar mi transformación física.

#### Acceptance Criteria

1. WHEN el usuario hace clic en "Ver Progreso" THEN el sistema SHALL abrir un modal con carrusel de fotos
2. WHEN hay fotos disponibles THEN el sistema SHALL mostrar navegación con botones anterior/siguiente
3. WHEN se muestra una foto THEN el sistema SHALL mostrar peso, fecha y notas asociadas
4. WHEN hay múltiples fotos THEN el sistema SHALL mostrar indicadores de progreso (puntos)
5. IF no hay fotos THEN el sistema SHALL mostrar mensaje "No hay fotos de progreso disponibles"

### Requirement 9

**User Story:** Como usuario avanzado, quiero configurar información adicional como altura, edad y estilo de vida, para que pueda obtener predicciones más precisas.

#### Acceptance Criteria

1. WHEN el usuario hace clic en "Config Avanzada" THEN el sistema SHALL abrir un modal con campos para altura, edad, sexo y estilo de vida
2. WHEN se completa la configuración THEN el sistema SHALL calcular y mostrar el IMC automáticamente
3. WHEN hay configuración avanzada THEN el sistema SHALL usar estos datos para mejorar las predicciones
4. WHEN se calcula el IMC THEN el sistema SHALL mostrar la categoría (Normal, Sobrepeso, etc.)
5. WHEN hay perfil completo THEN el sistema SHALL mostrar "Pred IA" con fecha más precisa

### Requirement 10

**User Story:** Como usuario, quiero que la aplicación se adapte automáticamente al modo oscuro del sistema, para que tenga una experiencia visual consistente.

#### Acceptance Criteria

1. WHEN el sistema está en modo claro THEN la aplicación SHALL usar colores claros automáticamente
2. WHEN el sistema está en modo oscuro THEN la aplicación SHALL usar colores oscuros automáticamente
3. WHEN cambia el modo del sistema THEN la aplicación SHALL actualizar los colores sin reiniciar
4. WHEN se usan colores dinámicos THEN el sistema SHALL mantener la legibilidad en ambos modos
5. WHEN se muestran gráficos THEN los colores de tendencia SHALL ser visibles en ambos modos