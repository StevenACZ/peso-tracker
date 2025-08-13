# CLAUDE.md

## Project Overview
PesoTracker is a macOS weight tracking app built with SwiftUI. Features: JWT authentication with refresh tokens, smart caching with photo expiration, weight tracking, goals, progress photos, and Cloudflare-optimized API integration.

## 🏗️ App Architecture

### Pattern: MVVM + SwiftUI
- **Models**: Data structures (User, Weight, Goal, APIResponse)
- **Views**: SwiftUI components with modular structure
- **ViewModels**: Business logic with @Published properties
- **Services**: API communication, caching, authentication

### Core Systems
- **Authentication**: JWT + refresh tokens with auto-renewal
- **Networking**: Auto-retry HTTP client with token refresh
- **Caching**: LRU cache with photo expiration intelligence
- **Image Processing**: Universal drag & drop + multi-format support
- **Error Handling**: Beautiful modals with crash-safe message parsing

## 📁 Key Files Structure

### 🔐 Authentication & Security
- `Services/AuthService.swift` - JWT + refresh tokens + auto-renewal
- `Utils/JWTHelper.swift` - Local JWT validation (instant startup)
- `Models/User.swift` - AuthResponse with accessToken + refreshToken

### 🌐 Networking & API
- `Services/Networking/HTTPClient.swift` - Auto-retry + token refresh
- `Services/APIService.swift` - Modular HTTP client
- `Models/APIResponse.swift` - Pagination + metadata
- **Endpoints**: `/auth/login`, `/auth/refresh`, `/weights`, `/dashboard`

### 💾 Smart Caching System
- `Services/CacheService.swift` - LRU cache with photo expiration (550+ lines)
- **Cache Types**: Table, Chart, Progress photos
- **Intelligence**: Auto-cleanup expired photos, memory pressure handling
- **Behavior**: Instant loading, smart invalidation on CRUD operations

### 📸 Image Handling & Upload
- `ViewModels/Components/ImageHandler.swift` - Universal drag & drop
- `Views/.../PhotoUploadSection.swift` - Enhanced onDrop with UTTypes
- **Formats**: JPEG, PNG, GIF, HEIC, TIFF + HDR support
- **Sources**: Finder, browsers, Preview, Fotos, creative apps
- **Processing**: 80% quality, max 1024px, multipart upload

### ⚖️ Weight Management
- `Services/WeightService.swift` - CRUD + cache invalidation
- `ViewModels/WeightEntryViewModel.swift` - Form logic + validation
- `Views/Dashboard/Modals/AddWeightModal.swift` - Create/Edit modal
- **Features**: Date validation, weight range (1-1000kg), notes, photos

### 📊 Dashboard & Progress
- `Views/Dashboard/MainDashboardView.swift` - 35% sidebar, 65% content
- `Services/DashboardService.swift` - Dashboard data
- `Views/Dashboard/Modals/ViewProgressModal.swift` - Photo gallery
- **Components**: Charts, tables, progress photos, export options

### 🎨 UI Components & Modals

#### Error Handling System
- `Views/Auth/Components/ErrorModal.swift` - Professional error modals
- **Features**: Crash-safe JSON parsing, contextual titles, spring animations
- **Messages**: Extracts clean user messages from server errors
- **Design**: Consistent with Auth components (red theme, icons)

#### Loading & Protection
- `Views/Dashboard/Components/LoadingOverlay.swift` - Multi-context loading
- **Protection**: Complete UI blocking during form submission
- **Layers**: Overlay + disabled states + component guards
- **Context**: "Guardando peso...", "Cargando datos..."

#### Form Components (All Loading-Protected)
- `WeightInputSection.swift` - Input disabled during loading
- `DatePickerSection.swift` - Picker blocked during loading
- `NotesSection.swift` - TextEditor disabled during loading
- `PhotoUploadSection.swift` - Complete photo blocking + drag protection

#### Progress Components (Modular)
- `ViewProgressComponents/ProgressInfoComponents.swift` - Photo counter ("Foto 1 de X")
- `ProgressPhotoViewer.swift` - Main photo display
- `ProgressDataManager.swift` - State management
- `ProgressStateViews.swift` - Loading/Error/Empty states

## 🚀 Key Features & Systems

### Cloudflare Integration
- **Refresh Tokens**: 15-min access + 7-day refresh + auto-renewal
- **Photo URLs**: Expiration tracking with auto-cleanup
- **Smart Caching**: Server metadata + client intelligence
- **Performance**: Lightning-fast startup with local JWT validation

### Drag & Drop System
- **Universal**: Works with all macOS apps (Finder, browsers, etc.)
- **Robust**: Type hierarchy with fallback mechanisms
- **Debug**: Comprehensive logging for troubleshooting
- **Error Recovery**: Fixed kDragIPCCompleted issues

### Form Protection & Validation
- **Multi-Layer**: Loading overlay + disabled states + guards
- **Real-time**: Combine-based validation
- **Error Prevention**: Blocks interaction during async operations
- **Visual Feedback**: Grayed elements + loading indicators

### Cache Intelligence
- **Photo Expiration**: `photo.isExpired` computed property
- **Auto-cleanup**: `cleanupExpiredPhotoCache()` method
- **Debug Stats**: Expired photo tracking
- **Memory Management**: LRU (50 items, 10MB limit)

## 🔧 Development Info

### Build & Run
- **Command**: `xcodebuild -scheme PesoTracker -configuration Debug build`
- **Target**: macOS app (1000x700 min, 1200x800 default)
- **Language**: Spanish localization
- **Theme**: Green color scheme

### Data Flow
1. **Authentication**: Login → JWT tokens → Keychain storage
2. **Data Loading**: API call → Cache check → UI update
3. **Image Upload**: Drag/select → Validation → Multipart upload
4. **Error Handling**: API error → Parse message → Show ErrorModal
5. **Cache**: CRUD operation → Invalidate cache → Refresh UI

### Key Patterns
- **Async/Await**: All API calls use modern async patterns
- **Combine**: Real-time form validation and data binding
- **Thread Safety**: @MainActor for UI updates
- **Error Recovery**: Graceful fallbacks and user feedback
- **Modular Design**: Reusable components and services

## 📝 Quick Reference

### Common Tasks
- **Add Weight**: Modal with drag & drop, validation, error handling
- **View Progress**: Photo gallery with "Foto X de Y" counter
- **Authentication**: Auto-refresh tokens, graceful logout
- **Caching**: Instant loading with smart invalidation
- **Error Display**: Beautiful modals instead of system alerts

### Key Services
- `AuthService` - Authentication & token management
- `WeightService` - Weight CRUD operations
- `CacheService` - Smart caching with expiration
- `DashboardService` - Dashboard data aggregation

### UI Patterns
- **Modals**: Consistent design with animations
- **Loading**: Multi-context overlays with blocking
- **Errors**: Professional modals with message parsing
- **Forms**: Real-time validation with protection