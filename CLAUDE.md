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
- **APIService**: Generic HTTP client with JWT authentication, error handling, and multipart upload support
- **AuthService**: Handles user authentication, token management, and session validation
- **DashboardService**: Manages dashboard data fetching and aggregation

#### ViewModels (`/ViewModels/`)
- **AuthViewModel**: Manages authentication state, form validation, and user session
- **DashboardViewModel**: Handles dashboard data state and user interactions

#### Models (`/Models/`)
- **User**: User account with flexible ID handling (String/Int) and robust date parsing
- **Weight**: Weight tracking entries
- **Goal**: User goals and targets
- **Photo**: Photo uploads for progress tracking
- **UserProfile**: Extended user profile information

### Configuration Management
- **Environment Variables**: API configuration via xcconfig files (`Debug.xcconfig`, `Release.xcconfig`)
- **Constants**: Centralized configuration in `Utils/Constants.swift`
- **Keychain**: Secure storage for JWT tokens and sensitive data

### API Integration
- **Base URL**: Configured via xcconfig (API_PROTOCOL, API_HOST, API_PORT)
- **Authentication**: Bearer token-based with automatic token refresh
- **Error Handling**: Comprehensive error types with localized Spanish messages
- **Endpoints**: RESTful API for auth, weights, goals, photos, profile, and dashboard

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
- **Dual Data Streams**: Separate paginated and complete datasets for optimal performance
- **Paginated Data** (`weights[]`): 5 records per page for table display with navigation controls
- **Complete Data** (`allWeights[]`): Full user history (up to 1000 records) for charts and statistics
- **Data Synchronization**: Both streams updated on create/update/delete operations
- **Statistics Independence**: Charts and analytics use complete dataset regardless of table pagination
- **Smart Pagination**: Previous/Next controls with disabled states when not applicable

### Error Handling Strategy
- API errors are localized to Spanish
- Network errors include retry logic
- Authentication failures trigger automatic token cleanup
- User-friendly error messages displayed in UI

### Code Conventions
- SwiftUI for all UI components
- Async/await for API calls
- Combine for reactive state management
- Comprehensive error handling with custom APIError types
- Spanish localization for user-facing messages