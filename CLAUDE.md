# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PesoTracker is a weight tracking macOS application built with SwiftUI. It features user authentication, weight tracking, goal setting, photo uploads, and progress visualization through an integrated dashboard.

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
- **DashboardService**: Manages dashboard data fetching and aggregation from unified `/dashboard` endpoint
- **WeightService**: Unified weight management service with CRUD operations and photo upload support

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

### Code Conventions
- SwiftUI for all UI components
- Async/await for API calls
- Combine for reactive state management
- Comprehensive error handling with custom APIError types
- Spanish localization for user-facing messages
- Multipart form data for all file uploads