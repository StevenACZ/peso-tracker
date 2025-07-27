# Implementation Plan

- [x] 1. Setup proyecto base y arquitectura MVVM

  - Configurar estructura de carpetas según el diseño (Models, ViewModels, Views, Services, Utils)
  - Crear archivo Constants.swift con configuraciones base y URL de API
  - Implementar modelos de datos básicos (User, Weight, Goal, Photo, UserProfile) con Codable
  - _Requirements: 1.1, 2.1, 3.1_

- [x] 2. Implementar capa de servicios y networking

  - [x] 2.1 Crear APIService base con manejo de JWT

    - Implementar clase APIService con métodos genéricos para requests HTTP
    - Agregar manejo automático de headers JWT Bearer token
    - Implementar manejo de errores de red y respuestas HTTP
    - _Requirements: 1.1, 2.1_

  - [x] 2.2 Implementar AuthService para autenticación
    - Crear métodos login() y register() que consuman endpoints /auth/login y /auth/register
    - Implementar persistencia de token JWT en Keychain
    - Agregar método logout() que elimine token almacenado
    - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.5_

- [x] 3. Crear sistema de autenticación completo

  - [x] 3.1 Implementar AuthViewModel

    - Crear AuthViewModel como ObservableObject con @Published properties para estado
    - Implementar métodos login(), register(), logout() que usen AuthService
    - Agregar validación de campos y manejo de estados de loading/error
    - _Requirements: 1.1, 1.2, 1.4, 2.1, 2.2, 2.3_

  - [x] 3.2 Crear LoginView con formulario de autenticación

    - Implementar vista SwiftUI con campos email y password
    - Agregar validación en tiempo real y estados de error
    - Conectar con AuthViewModel para manejo de login
    - Incluir navegación a RegisterView
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 3.3 Crear RegisterView con formulario de registro
    - Implementar vista SwiftUI con campos username, email y password
    - Agregar validación de formato de email y fortaleza de contraseña
    - Conectar con AuthViewModel para manejo de registro
    - Incluir navegación de regreso a LoginView
    - _Requirements: 1.1, 1.2, 1.4, 1.5_

- [x] 4. Implementar navegación principal y ContentView

  - Modificar ContentView para manejar estado de autenticación
  - Implementar lógica de redirección automática basada en token JWT
  - Agregar verificación de token al iniciar la aplicación
  - Crear navegación condicional entre LoginView y MainDashboardView
  - _Requirements: 2.4, 3.4_

- [ ] 5. Crear estructura base del dashboard

  - [ ] 5.1 Implementar MainDashboardView con layout dividido

    - Crear vista principal con HStack dividido en proporción 35/65
    - Implementar SummaryPanelView para panel izquierdo
    - Implementar DataPanelView para panel derecho
    - Agregar manejo responsivo para diferentes tamaños de ventana
    - _Requirements: 3.1, 3.2, 3.3_

  - [ ] 5.2 Crear DashboardViewModel para coordinación de datos
    - Implementar ViewModel central que coordine datos de peso, metas y fotos
    - Agregar @Published properties para todos los datos del dashboard
    - Implementar métodos para cargar datos iniciales del usuario
    - Conectar con servicios de Weight, Goal y Photo
    - _Requirements: 3.3, 3.5_

- [ ] 🚀 **MVP CHECKPOINT**: App funcional básica

  - En este punto tendrás una app que se puede abrir, registrar/login usuarios, y mostrar dashboard vacío
  - Funcionalidades: Registro, Login, Dashboard básico con layout, Logout
  - Perfecto para testing inicial y validar que todo funciona antes de agregar features complejas
  - _Requirements: 1.1, 1.2, 2.1, 2.2, 2.5, 3.1, 3.2_

- [ ] 6. Implementar gestión de pesos

  - [ ] 6.1 Crear WeightService para operaciones CRUD

    - Implementar métodos para GET, POST, PATCH, DELETE en endpoint /weights
    - Agregar soporte para paginación y filtros de fecha
    - Implementar subida de fotos con multipart/form-data
    - _Requirements: 4.1, 4.4, 4.5_

  - [ ] 6.2 Implementar WeightViewModel

    - Crear ViewModel con @Published array de weights y estados de loading
    - Implementar métodos addWeight(), updateWeight(), deleteWeight()
    - Agregar validación de datos de peso (número positivo)
    - Conectar con WeightService para operaciones de API
    - _Requirements: 4.1, 4.2, 4.5, 4.6_

  - [ ] 6.3 Crear WeightEntryModal para agregar/editar pesos

    - Implementar modal SwiftUI con campos peso, fecha, notas y foto
    - Agregar DatePicker para selección de fecha
    - Implementar PhotoUploadView component para selección de imágenes
    - Conectar con WeightViewModel para guardar datos
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

  - [ ] 6.4 Crear WeightRowView y tabla de pesos
    - Implementar componente para mostrar fila individual de peso
    - Agregar botones de editar y eliminar con confirmación
    - Crear tabla completa en DataPanelView con headers
    - Implementar indicadores visuales para fotos y notas
    - _Requirements: 4.6, 3.3_

- [ ] 7. Implementar sistema de metas y milestones

  - [ ] 7.1 Crear GoalService para operaciones de metas

    - Implementar métodos CRUD para endpoint /goals
    - Agregar lógica para metas principales y milestones
    - Implementar eliminación en cascada (meta principal elimina milestones)
    - _Requirements: 5.1, 5.4, 6.5_

  - [ ] 7.2 Implementar GoalViewModel

    - Crear ViewModel con @Published properties para metas y milestones
    - Implementar métodos createGoal(), updateGoal(), deleteGoal()
    - Agregar lógica para solo permitir un milestone activo
    - Conectar con GoalService para operaciones de API
    - _Requirements: 5.1, 5.2, 5.4, 6.1, 6.2, 6.3_

  - [ ] 7.3 Crear GoalEditModal para crear/editar metas

    - Implementar modal con campos peso objetivo y fecha
    - Agregar diferenciación entre meta principal y milestone
    - Implementar sugerencia automática para milestones (25% del progreso)
    - Conectar con GoalViewModel para guardar datos
    - _Requirements: 5.1, 5.2, 6.1_

  - [ ] 7.4 Crear GoalCard y MilestoneCard components
    - Implementar GoalCard para mostrar meta principal con progreso
    - Crear MilestoneCard para milestone activo
    - Agregar botones de editar y eliminar con confirmación
    - Implementar indicadores visuales de progreso
    - _Requirements: 5.5, 6.2, 6.4_

- [ ] 8. Implementar motor de predicciones

  - [ ] 8.1 Crear PredictionEngine con cálculos básicos

    - Implementar calculateWeeklyAverage() para promedio de pérdida/ganancia
    - Crear calculateGoalDate() para predicción básica de fecha de meta
    - Agregar getTrendColor() para colores dinámicos según tendencia
    - _Requirements: 7.1, 7.2, 7.4, 7.5_

  - [ ] 8.2 Integrar predicciones en dashboard
    - Conectar PredictionEngine con DashboardViewModel
    - Mostrar predicciones actualizadas en GoalCard
    - Implementar colores dinámicos en gráficos y componentes
    - Agregar indicadores visuales de tendencia (verde/amarillo/rojo)
    - _Requirements: 7.3, 7.4, 7.5_

- [ ] 9. Crear sistema de progreso fotográfico

  - [ ] 9.1 Implementar PhotoService y PhotoViewModel

    - Crear PhotoService para operaciones con endpoint /photos
    - Implementar PhotoViewModel con manejo de imágenes
    - Agregar carga lazy de imágenes para performance
    - _Requirements: 8.1, 8.2_

  - [ ] 9.2 Crear PhotoProgressModal con carrusel
    - Implementar modal con navegación anterior/siguiente
    - Agregar indicadores de progreso (puntos)
    - Mostrar información de peso, fecha y notas para cada foto
    - Implementar AsyncImage para carga de imágenes remotas
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ] 10. Implementar configuración avanzada

  - [ ] 10.1 Crear ProfileViewModel y UserProfile management

    - Implementar ViewModel para manejo de perfil avanzado
    - Agregar persistencia local de datos de perfil
    - Crear métodos para cálculo de IMC y categorización
    - _Requirements: 9.1, 9.2, 9.4_

  - [ ] 10.2 Crear AdvancedProfileModal

    - Implementar modal con campos altura, edad, sexo, estilo de vida
    - Agregar cálculo automático y display de IMC
    - Mostrar categoría de IMC (Normal, Sobrepeso, etc.)
    - Conectar con ProfileViewModel para persistencia
    - _Requirements: 9.1, 9.2, 9.3, 9.4_

  - [ ] 10.3 Integrar predicción avanzada
    - Extender PredictionEngine con calculateAdvancedGoalDate()
    - Implementar cálculos de BMR y factores de actividad
    - Mostrar "Pred IA" en dashboard cuando hay perfil completo
    - _Requirements: 9.5_

- [ ] 11. Implementar gráfico de progreso

  - Crear WeightChartView con líneas de datos reales y predicción
  - Implementar marcadores para metas y milestones
  - Agregar colores dinámicos según tendencia de peso
  - Conectar con DashboardViewModel para datos actualizados
  - _Requirements: 3.2, 7.4, 7.5_

- [ ] 12. Completar SummaryPanelView

  - Implementar sección de resumen personal (peso inicial, actual, pérdida, promedio)
  - Agregar botones de acción (Nueva Meta, Milestone, Ver Progreso, Logout)
  - Mostrar predicción avanzada cuando esté disponible
  - Conectar todos los componentes con sus respectivos ViewModels
  - _Requirements: 3.2, 2.5_

- [ ] 13. Implementar modo oscuro automático

  - Configurar @Environment(\.colorScheme) en todas las vistas
  - Usar colores adaptativos (.systemBackground, .label, etc.)
  - Implementar efectos de material (.regularMaterial) para cristal adaptable
  - Verificar legibilidad en ambos modos
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

- [ ] 14. Agregar manejo de errores y estados de loading

  - Implementar AppError enum con casos específicos
  - Agregar @Published errorMessage en todos los ViewModels
  - Crear componentes de loading states y skeleton loading
  - Implementar alerts y banners para mostrar errores al usuario
  - _Requirements: 1.5, 2.3, 4.5, 5.4_

- [ ] 15. Implementar flujo de onboarding para nuevos usuarios

  - Detectar cuando dashboard está vacío (sin pesos)
  - Mostrar mensaje "¡Comencemos! Agrega tu primer peso"
  - Auto-abrir WeightEntryModal para primer registro
  - Mostrar mensaje para establecer meta después del primer peso
  - _Requirements: 3.4, 3.5_

- [ ] 16. Testing y polish final
  - Escribir unit tests para ViewModels y PredictionEngine
  - Crear integration tests para flujo de autenticación
  - Implementar UI tests para navegación principal
  - Optimizar performance y memory usage
  - Verificar funcionamiento en diferentes tamaños de ventana macOS
  - _Requirements: Todos los requirements de funcionalidad y UX_
