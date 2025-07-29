# BMI Calculator Components

Esta carpeta contiene todos los componentes modularizados para la funcionalidad de calculadora de IMC.

## Estructura de Archivos

### 📁 Archivo Principal
- **`BMICalculatorComponents.swift`** - Archivo consolidado con todos los componentes y lógica

### 📁 Componentes Individuales (Opcionales)
- **`BMIInputField.swift`** - Campo de entrada reutilizable con validación numérica
- **`BMIGenderSelector.swift`** - Selector de género con radio buttons
- **`BMIResultsView.swift`** - Vista de resultados con categoría y rango ideal
- **`BMIModalButtons.swift`** - Botones de acción del modal
- **`BMICalculator.swift`** - Lógica central de cálculo, validación y categorización

### 📁 Documentación
- **`BMIComponents.swift`** - Índice de componentes y guía de uso
- **`README.md`** - Esta documentación

## Enfoque Consolidado

Hemos implementado un **enfoque consolidado** que ofrece:

1. **Archivo Principal**: `BMICalculatorComponents.swift` contiene todos los componentes y lógica en un solo lugar
2. **Fácil Mantenimiento**: Todo el código relacionado con BMI está centralizado
3. **Sin Conflictos**: Evita problemas de importación y nombres duplicados

## Ventajas de la Modularización

### ✅ Reutilización
- Los componentes pueden usarse en otros modales o vistas
- Fácil mantenimiento y testing individual

### ✅ Separación de Responsabilidades
- UI separada de la lógica de negocio
- Cada componente tiene una función específica

### ✅ Escalabilidad
- Fácil agregar nuevas funcionalidades
- Estructura clara para nuevos desarrolladores

## Uso de Componentes

### BMIInputField
```swift
BMIInputField(
    title: "Altura (cm)",
    placeholder: "Ej: 175",
    text: $height
)
```

### BMIGenderSelector
```swift
BMIGenderSelector(selectedGender: $selectedGender)
```

### BMIResultsView
```swift
BMIResultsView(bmi: calculatedBMI, height: height)
```

### BMICalculator (Lógica)
```swift
// Validación
let result = BMICalculator.validateInputs(height: height, weight: weight)

// Cálculo
let bmi = BMICalculator.calculate(height: heightValue, weight: weightValue)

// Categorización
let category = BMICalculator.getCategory(for: bmi)
let color = BMICalculator.getCategoryColor(for: bmi)
```

## Patrón Recomendado

Este patrón se puede aplicar a otros modales:
1. Crear carpeta `[ModalName]Components`
2. Separar UI components en archivos individuales
3. Crear archivo de lógica de negocio
4. Documentar con README
5. Crear índice de componentes

## Próximos Pasos

Considerar modularizar:
- `AddWeightModal` → `AddWeightComponents/`
- `AddGoalModal` → `AddGoalComponents/`
- `AdvancedSettingsModal` → `AdvancedSettingsComponents/`