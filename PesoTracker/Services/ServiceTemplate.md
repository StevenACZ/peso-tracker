# Service Architecture Template

Este documento define la arquitectura estándar para servicios en PesoTracker.

## Estructura Estándar de Servicios

### Patrón de Arquitectura Modular

Cada servicio principal debe seguir el patrón modular con componentes separados:

```swift
// MARK: - Service Principal
class ExampleService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = ExampleService()
    
    // MARK: - Modular Components  
    private let dataProvider = ExampleDataProvider()
    private let statisticsCalculator = ExampleStatisticsCalculator()
    
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var items: [ExampleModel] = []
    @Published var error: String?
    
    // MARK: - Initialization
    private init() {
        print("🔥 [EXAMPLE SERVICE] Initializing service")
    }
    
    // MARK: - Main Operations
    @MainActor
    func loadItems() async {
        isLoading = true
        error = nil
        
        do {
            items = try await dataProvider.loadItems()
        } catch {
            print("❌ [EXAMPLE SERVICE] Error loading items: \\(error)")
            self.error = "Error message: \\(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Methods (Delegated to Statistics Calculator)
    func getFilteredItems() -> [ExampleModel] {
        return statisticsCalculator.getFilteredItems(from: items)
    }
    
    // MARK: - Clear Data
    func clearData() {
        items = []
        error = nil
    }
}
```

### DataProvider (Lógica de API)

```swift
// MARK: - Example Data Provider
class ExampleDataProvider {
    
    // MARK: - Properties
    private let apiService = APIService.shared
    
    // MARK: - API Operations
    func loadItems() async throws -> [ExampleModel] {
        print("🔥 [EXAMPLE DATA PROVIDER] Loading items from API...")
        
        let items = try await apiService.get(
            endpoint: Constants.API.Endpoints.example,
            responseType: [ExampleModel].self
        )
        
        print("✅ [DEBUG] Items loaded: \\(items.count) records")
        return items
    }
    
    func createItem(data: ExampleRequest) async throws -> ExampleModel {
        print("🔥 [EXAMPLE DATA PROVIDER] Creating new item...")
        
        let createdItem = try await apiService.post(
            endpoint: Constants.API.Endpoints.example,
            body: data,
            responseType: ExampleModel.self
        )
        
        print("✅ [EXAMPLE DATA PROVIDER] Item created successfully")
        return createdItem
    }
}
```

### StatisticsCalculator (Lógica de Negocio)

```swift
// MARK: - Example Statistics Calculator
class ExampleStatisticsCalculator {
    
    // MARK: - Filtering Methods
    func getFilteredItems(from items: [ExampleModel]) -> [ExampleModel] {
        return items.filter { /* logic */ }
    }
    
    // MARK: - Statistics Calculations
    func getTotalItems(from items: [ExampleModel]) -> Int {
        return items.count
    }
    
    // MARK: - UI Helper Methods
    func hasItemData(items: [ExampleModel]) -> Bool {
        return !items.isEmpty
    }
    
    func getFormattedTotal(from items: [ExampleModel]) -> String {
        return "\\(getTotalItems(from: items)) items"
    }
}
```

## Estructura de Carpetas

```
Services/
├── APIService.swift (base service)
├── AuthService.swift (authentication specific)
├── DashboardService.swift (orchestrator)
├── ExampleFeature/
│   ├── ExampleService.swift (main service)
│   ├── ExampleDataProvider.swift (API logic)
│   └── ExampleStatisticsCalculator.swift (business logic)
└── Networking/ (HTTP utilities)
    ├── HTTPClient.swift
    ├── AuthenticationHandler.swift
    └── MultipartFormBuilder.swift
```

## Convenciones de Nomenclatura

### Servicios Principales
- **Nombre**: `FeatureService` (ej: `WeightService`, `GoalService`)
- **Ubicación**: `/Services/Feature/FeatureService.swift`
- **Patrón**: Singleton con `shared` instance

### DataProviders
- **Nombre**: `FeatureDataProvider`
- **Responsabilidad**: Todas las operaciones de API (GET, POST, PUT, DELETE)
- **Ubicación**: `/Services/Feature/FeatureDataProvider.swift`

### StatisticsCalculators
- **Nombre**: `FeatureStatisticsCalculator`
- **Responsabilidad**: Cálculos, filtros, transformaciones de datos
- **Ubicación**: `/Services/Feature/FeatureStatisticsCalculator.swift`

## Mejores Prácticas

### 1. Separación de Responsabilidades
- **Service**: Orquestación, estado (@Published), manejo de errores
- **DataProvider**: Comunicación con API, serialización/deserialización
- **StatisticsCalculator**: Lógica de negocio, cálculos, filtros

### 2. Delegación Consistente
```swift
// ✅ Bueno - Delegar a componentes modulares
func getFilteredItems() -> [Item] {
    return statisticsCalculator.getFilteredItems(from: items)
}

// ❌ Malo - Lógica directa en el service
func getFilteredItems() -> [Item] {
    return items.filter { $0.isActive }
}
```

### 3. Manejo de Errores
```swift
// Siempre propagar errores con contexto
do {
    items = try await dataProvider.loadItems()
} catch {
    print("❌ [SERVICE NAME] Error loading items: \\(error)")
    self.error = "Error al cargar elementos: \\(error.localizedDescription)"
}
```

### 4. Logging Consistente
- Usar emojis para identificar servicios: 🔥, ⚖️, 🎯, 📸
- Formato: `[SERVICE NAME] Action description`
- Incluir datos relevantes sin exponer información sensible

### 5. Extensiones para UI Helpers
```swift
// MARK: - Extensions for UI Helpers (Delegated to Statistics Calculator)
extension ExampleService {
    
    var hasData: Bool {
        return statisticsCalculator.hasItemData(items: items)
    }
    
    var formattedTotal: String {
        return statisticsCalculator.getFormattedTotal(from: items)
    }
}
```

## Servicios Actuales

### Servicios Principales (Siguen el patrón estándar)
- ✅ **WeightService**: `/Services/Weight/`
- ✅ **GoalService**: `/Services/Goal/`  
- ✅ **PhotoService**: `/Services/Photo/`
- ✅ **AuthService**: `/Services/AuthService.swift`
- ✅ **DashboardService**: `/Services/DashboardService.swift`

### Servicios Base
- **APIService**: Cliente HTTP base con componentes modulares
- **Networking**: Utilidades HTTP (HTTPClient, AuthenticationHandler, MultipartFormBuilder)

### Servicios Legacy (Mantener por compatibilidad)
- **WeightEntryService**: Implementación alternativa con Int IDs
- **WeightEntry/**: Servicios específicos para entrada de pesos con imágenes NSImage

## Agregar Nuevos Endpoints

Para agregar un nuevo endpoint a un servicio existente:

1. **Agregar al DataProvider**: Nueva función en `FeatureDataProvider`
2. **Agregar al Service**: Método que usa el DataProvider
3. **Agregar cálculos**: Si requiere lógica, agregarla al StatisticsCalculator
4. **Probar**: Verificar que sigue las convenciones

Para crear un nuevo servicio completamente:

1. **Crear carpeta**: `/Services/NewFeature/`
2. **Implementar patrón**: Service + DataProvider + StatisticsCalculator
3. **Seguir convenciones**: Nomenclatura, logging, manejo de errores
4. **Documentar**: Agregar a esta lista de servicios