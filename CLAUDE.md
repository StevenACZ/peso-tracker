# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PesoTracker is a weight tracking macOS application built with SwiftUI. It features user authentication, weight tracking, goal setting, photo uploads, progress visualization, and intelligent caching system for optimal performance.

## Quick Reference - Key Locations

### Main UI Components
- **Login/Register**: `Views/Auth/` - AuthViewModel handles state
- **Dashboard**: `Views/Dashboard/MainDashboardView.swift` - Split layout (35% sidebar, 65% content)
- **Settings Dropdown**: `Views/Dashboard/Components/SettingsDropdown.swift` - Contains logout, BMI calculator, advanced settings
- **Weight Table**: `Views/Dashboard/Components/WeightRecordsView.swift` - Paginated with smart cache
- **Add/Edit Weight**: `Views/Dashboard/Modals/AddWeightModal.swift` - Photo upload, validation
- **Progress Modal**: `Views/Dashboard/Modals/ViewProgressModal.swift` - Photo navigation
- **BMI Calculator**: `Views/Dashboard/Modals/BMICalculatorModal.swift` - Medical classifications
- **Goal Management**: `Views/Dashboard/Modals/AddGoalModal.swift` - Create/edit goals

### Core Services
- **Authentication**: `Services/AuthService.swift` - JWT token management
- **API Communication**: `Services/APIService.swift` - Generic HTTP client
- **Dashboard Data**: `Services/DashboardService.swift` - Unified endpoint, logout functionality
- **Weight Operations**: `Services/WeightService.swift` - CRUD with cache invalidation
- **Smart Cache**: `Services/CacheService.swift` - Thread-safe dual cache (table + chart) with LRU management
- **Goal Management**: `Services/GoalService.swift` - Goal CRUD operations

### ViewModels
- **Auth State**: `ViewModels/AuthViewModel.swift` - Login/register/logout
- **Dashboard State**: `ViewModels/DashboardViewModel.swift` - Data aggregation, pagination
- **Weight Forms**: `ViewModels/WeightEntryViewModel.swift` - Add/edit with validation

### Data Models
- **User**: `Models/User.swift` - Flexible ID handling (String/Int)
- **Weight**: `Models/Weight.swift` - With nested WeightPhoto support
- **Goal**: `Models/Goal.swift` - Simplified structure
- **API Responses**: `Models/APIResponse.swift` - Paginated and error responses

## Development Commands

### Building and Running
- **Build**: Use Xcode to build the project (⌘+B) or via command line with `xcodebuild`
- **Run**: Launch from Xcode (⌘+R) or build and run the generated `.app` file
- **Clean**: Product → Clean Build Folder in Xcode or `xcodebuild clean`

### Project Structure
- **Target**: PesoTracker (macOS app)
- **Minimum Window Size**: 1000x700
- **Default Window Size**: 1200x800
- **Bundle Identifier**: com.pesotracker.app

## Architecture

### Core Architecture Pattern
- **MVVM Architecture**: ViewModels manage business logic and state, Views handle UI presentation
- **Service Layer**: Centralized services for API communication, authentication, and data management
- **Reactive Programming**: Uses Combine framework extensively for state management and form validation

### Key Components

#### Services (`/Services/`)
- **APIService**: Generic HTTP client with JWT authentication, error handling, and multipart upload support (POST/PATCH)
- **AuthService**: Handles user authentication, token management, and session validation
- **DashboardService**: Manages dashboard data fetching and aggregation from unified `/dashboard` endpoint. **Logout**: `DashboardService.logout()` clears data, cache, and JWT token
- **WeightService**: Unified weight management service with CRUD operations, photo upload support, and automatic cache invalidation
- **CacheService**: Thread-safe singleton for table pagination caching with LRU cleanup, memory management, and automatic invalidation

#### ViewModels (`/ViewModels/`)
- **AuthViewModel**: Manages authentication state, form validation, and user session
- **DashboardViewModel**: Handles dashboard data state, smart pagination navigation, and user interactions
- **WeightEntryViewModel**: Manages weight entry forms with photo upload, validation, and editing capabilities

#### Models (`/Models/`)
- **User**: User account with flexible ID handling (String/Int) and robust date parsing
- **Weight**: Weight tracking entries with nested WeightPhoto support for unified API responses
- **WeightPhoto**: Photo model with thumbnailUrl, mediumUrl, and fullUrl for weight images
- **Goal**: User goals and targets
- **Photo**: Photo uploads for progress tracking (legacy, maintained for compatibility)
- **UserProfile**: Extended user profile information

### Configuration Management
- **Environment Variables**: API configuration via xcconfig files (`Debug.xcconfig`, `Release.xcconfig`)
- **Constants**: Centralized configuration in `Utils/Constants.swift`
- **Keychain**: Secure storage for JWT tokens and sensitive data

### API Integration
- **Base URL**: Configured via xcconfig (API_PROTOCOL, API_HOST, API_PORT)
- **Authentication**: Bearer token-based with automatic token refresh
- **Error Handling**: Comprehensive error types with localized Spanish messages
- **Unified Weight Endpoints**: New simplified API structure for weight management
  - `POST /weights` - Create weight with multipart form data (weight, date, notes, photo)
  - `PATCH /weights/:id` - Update weight with multipart form data
  - `GET /weights/:id` - Get single weight with full photo details
  - `DELETE /weights/:id` - Delete weight and associated photos
  - `GET /dashboard` - Unified dashboard data endpoint
  - `GET /weights/paginated` - Paginated weight list (hasPhoto boolean only)
  - `GET /weights/chart-data` - Chart data with time range filtering

### UI Architecture
- **Dashboard Layout**: Split view with left sidebar (35%) and right content panel (65%)
- **Authentication Flow**: Login/Register with real-time validation
- **Modular Components**: Reusable UI components in dedicated directories
- **Color Scheme**: Green-based color palette (updated from blue)
- **Button Patterns**: Consistent clickable areas using Text wrapping with PlainButtonStyle
- **Pagination Controls**: Smart navigation with disabled states and visual feedback
- **Modal Interactions**: Full button clickability across all modal dialogs

### Security & Data Handling
- **JWT Token Storage**: Secure keychain storage via KeychainHelper
- **Token Validation**: Automatic token expiration handling
- **Image Processing**: Configurable compression and size limits
- **Form Validation**: Real-time validation with visual feedback

### Key Constants
- **API Timeout**: 30 seconds
- **Password Requirements**: 6-128 characters
- **Username Requirements**: 3-50 characters
- **Weight Range**: 1.0-1000.0 units
- **Weight Precision**: 2 decimal places for all displays and calculations
- **Pagination Limit**: 5 weight records per page for table display
- **Complete Data Limit**: 1000 records for charts and statistics
- **Image Compression**: 80% quality, max 1024px

## Development Notes

### Authentication Flow
1. User credentials are validated in real-time
2. JWT tokens are stored securely in keychain
3. API requests automatically include Bearer authentication
4. Token expiration triggers automatic logout

### Dashboard Data Flow
1. DashboardService fetches aggregated data from `/dashboard` endpoint
2. DashboardViewModel manages state and user interactions
3. UI components reactively update based on ViewModel state

### Weight Data Architecture
- **Unified API Approach**: Single endpoints for weight management with automatic photo handling
- **Smart Photo Loading**: Paginated endpoint returns hasPhoto boolean, individual endpoint provides full photo details
- **Paginated Data** (`weights[]`): 5 records per page for table display with smart navigation, sorted by most recent first
- **Chart Data**: Separate optimized endpoint for visualization with time range filtering, defaults to 'all' records
- **Auto-Navigation**: Smart pagination that navigates to previous page when current page becomes empty after deletion
- **Photo Integration**: Photos are automatically handled through weight endpoints (no separate photo CRUD)
- **Time Range Options**: Chart supports "Todos" (all), "1 mes", "3 meses", "6 meses", "1 año" - removed "1 semana" option

### Error Handling Strategy
- API errors are localized to Spanish
- Network errors include retry logic
- Authentication failures trigger automatic token cleanup
- User-friendly error messages displayed in UI

### Photo Management
- **Unified Upload**: Photos uploaded via multipart form data with weight creation/update
- **Automatic Compression**: Images compressed to 80% quality with 1024px max dimension
- **Smart Preview**: Edit modal automatically fetches photo details when needed
- **Single Action**: "Cambiar foto" button replaces image (no separate delete needed)

### Logging Strategy
- **Minimal Logging**: Only essential user information logged on dashboard load
- **User Info Log**: `👤 [DASHBOARD] User: {username} ({email}) - ID: {id}` on login
- **Clean Console**: All debug logs removed for production readiness

### Progress Modal Implementation
- **ViewProgressModal**: Complete modal for viewing weight progress with photos
- **Real API Integration**: Connected to `/weights/progress` endpoint for actual user data
- **Dynamic Photo Navigation**: Tap-based navigation on image halves (left/right) for intuitive browsing
- **Progress Data Models**: `ProgressResponse` and `ProgressPhoto` models for API data structure
- **AsyncImage Loading**: Real photos loaded from server using `mediumUrl` for optimal quality/speed
- **Smart States**: Loading, error, and empty states with user-friendly messages
- **Mobile-Optimized**: 320px image height perfect for mobile photo aspect ratios
- **Spanish Localization**: Dates formatted in Spanish locale, weights displayed in kg format
- **Visual Progress**: Dynamic progress bar fills based on current photo position
- **Adaptive Theming**: Supports both light and dark mode automatically
- **Navigation Indicators**: Visual dots showing current photo position with navigation arrows
- **Complete/Close Logic**: Button changes to "Completar" (green) on last photo, "Cerrar" otherwise

### Goal Management Implementation
- **AddGoalModal**: Complete modal for creating and editing weight goals
- **Real API Integration**: Connected to `POST /goals` and `PATCH /goals/:id` endpoints
- **GoalService**: Dedicated service for goal CRUD operations with error handling
- **Simplified Goal Model**: Streamlined to match current API response structure
- **Custom Date Picker**: Reused DatePickerPopover component from weight modal
- **Form Validation**: Weight limits (0.1-1000 kg), required fields, and error states
- **Loading States**: ProgressView during API operations with disabled form
- **Spanish Localization**: All text and date formatting in Spanish
- **Adaptive Theming**: Full support for light/dark mode
- **Clean UI**: Green button styling, no gray borders, PlainButtonStyle usage
- **Data Format**: Sends `targetWeight` (Double) and `targetDate` (yyyy-MM-dd string)
- **Response Handling**: Parses API response with Int IDs and String weights
- **Dashboard Integration**: Automatic refresh after goal creation/update
- **Legacy Cleanup**: Removed all milestone, GoalType, and old endpoint references

### BMI Calculator Implementation
- **BMICalculatorModal**: Complete BMI calculator with professional medical interface
- **Settings Integration**: Added "Calcular IMC" option to settings dropdown menu
- **Comprehensive Form**: Height (cm), Weight (kg), Age, and Gender (radio buttons)
- **Medical Classifications**: 6-tier BMI categories with color-coded results
  - Bajo peso (<18): Light blue
  - Peso normal (18-25): Green
  - Exceso de peso (25-30): Yellow/Orange
  - Obesidad Grado I (30-35): Orange
  - Obesidad Grado II (35-40): Light red
  - Obesidad Grado III (40+): Red
- **Smart Results Display**: Shows BMI value, classification badge, and ideal weight range
- **Adaptive Layout**: Modal height adjusts based on calculation state (340px → 520px)
- **Conditional Spacing**: 16px separation when results shown, buttons at bottom when empty
- **Input Validation**: Realistic limits for height (<250cm) and weight (<500kg)
- **Ideal Weight Calculator**: Automatic calculation of healthy weight range (BMI 18.5-24.9)
- **Professional Styling**: Aligned inputs, squared classification badges, green app colors
- **Responsive Design**: Optimized 480px width with proper field alignment

### Smart Cache System Implementation ✅ COMPLETE
- **CacheService**: Thread-safe singleton with concurrent queue for optimal performance
- **Dual Cache Support**: Both table pagination and chart data caching with unified LRU management
- **Table Cache**: Stores `PaginatedResponse<Weight>` data with keys `"table_page_X"`
- **Chart Cache**: Stores `ChartDataResponse` data with keys `"chart_timeRange_page_X"`
- **LRU Strategy**: Least Recently Used cleanup when limits exceeded (50 total items max, 10MB limit)
- **Memory Management**: Automatic cleanup on app termination, inactive state, and memory pressure
- **Cache Invalidation**: Automatic clearing on weight create/update/delete operations and user logout
- **Thread Safety**: All operations use concurrent dispatch queue with barrier flags for writes
- **Logging**: Comprehensive cache operation logging with `[SMART CACHE]` prefix
- **Debug Support**: `getCacheStatus()` provides detailed cache statistics and memory usage information
- **App Lifecycle Integration**: NSApplication observers for proper cleanup on termination/inactive states

### Cache Behavior - Production Ready
- **Cache Hit**: Instant data loading from memory with "INSTANT" log indicator
- **Cache Miss**: Normal API call with data cached for future use
- **Auto-Invalidation**: Complete cache clearing when data changes (create/edit/delete weight)
- **Logout Integration**: Complete cache cleanup when user logs out via `DashboardService.logout()`
- **Memory Limits**: Automatic LRU cleanup when exceeding 50 total items or 10MB usage
- **App Lifecycle**: Cache cleared on app termination and cleaned during memory pressure
- **Performance Impact**: Significant improvement in navigation speed for previously visited pages
- **Memory Efficiency**: Approximate usage calculation (500 bytes per Weight record, 100 bytes per WeightPoint)

### Cache Integration Points
- **DashboardService**: Cache check before setting loading states in `loadTableData()` and `loadChartData()`
- **WeightService**: Automatic cache invalidation after successful create/update/delete operations
- **Settings Logout**: Complete cache clearing integrated into logout flow
- **Memory Management**: Configurable limits and automatic cleanup strategies

### UI Component Locations
- **Settings Dropdown**: `Views/Dashboard/Components/SettingsDropdown.swift` - Contains logout button with cache clearing
- **Left Sidebar**: `Views/Dashboard/Components/LeftSidebarPanel.swift` - Settings dropdown trigger
- **Weight Table**: `Views/Dashboard/Components/WeightRecordsView.swift` - Smart cached pagination data
- **Progress Chart**: `Views/Dashboard/Components/ProgressChartView.swift` - Smart cached chart data
- **Add/Edit Modals**: `Views/Dashboard/Modals/AddWeightModal.swift` - Triggers automatic cache invalidation

### Code Conventions
- SwiftUI for all UI components
- Async/await for API calls
- Combine for reactive state management
- Comprehensive error handling with custom APIError types
- Spanish localization for user-facing messages
- Multipart form data for all file uploads
- Thread-safe cache operations with concurrent queues