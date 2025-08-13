# CLAUDE.md

## Project Overview
PesoTracker is a macOS weight tracking app built with SwiftUI. Features: JWT authentication with refresh tokens, smart caching with photo expiration, weight tracking, goals, progress photos, and Cloudflare-optimized API integration.

## Key Files

### Services ⚡ CLOUDFLARE-READY
- `Services/AuthService.swift` - JWT auth + **refresh tokens** + auto-renewal ✅ UPGRADED
- `Services/Networking/HTTPClient.swift` - HTTP client + **auto-retry logic** + token refresh ✅ NEW
- `Services/APIService.swift` - Modular HTTP client architecture
- `Services/CacheService.swift` - Smart cache + **photo expiration** (550+ lines) ✅ ENHANCED
- `Services/DashboardService.swift` - Dashboard data + logout
- `Services/WeightService.swift` - Weight CRUD + cache invalidation
- `Services/GoalService.swift` - Goal management

### Models ✅ CLOUDFLARE-ENHANCED
- `Models/User.swift` - **AuthResponse** with accessToken + refreshToken + legacy support ✅ UPDATED
- `Models/APIResponse.swift` - **PaginationInfo** + hasNext/hasPrev + APIMetadata ✅ ENHANCED
- `Models/Weight.swift` - **WeightPhoto** + expiresIn + format + expiration logic ✅ UPGRADED
- `Models/Goal.swift` - Goal data structures

### UI Components
- `Views/Auth/` - Complete password reset flow ✅ COMPLETE
- `Views/Dashboard/MainDashboardView.swift` - Main dashboard (35% sidebar, 65% content)
- `Views/Dashboard/Components/RightContentPanel.swift` - Progress button (shows with weight data)
- `Views/Dashboard/Modals/ViewProgressModal.swift` - Progress photos with lazy loading

### Modular Components ✅ REFACTORED
- `Views/Dashboard/Modals/ViewProgressComponents/` - 5 focused components
- `Services/Export/` - 5 specialized export services

### Utils ✅ PERFORMANCE-ENHANCED
- `Utils/Constants.swift` - App constants + **/auth/refresh** endpoint ✅ UPDATED
- `Utils/Extensions.swift` - Centralized extensions
- `Utils/JWTHelper.swift` - **JWT validation** + local expiration check ✅ NEW

### Image Handling ✅ DRAG & DROP ENHANCED
- `ViewModels/Components/ImageHandler.swift` - **Universal drag & drop** + multi-format support ✅ UPGRADED
- `Views/Dashboard/Modals/AddWeightModalComponents/PhotoUploadSection.swift` - **Enhanced onDrop** + expanded UTTypes ✅ IMPROVED

## ⚡ Cloudflare Integration ✅ NEW

### Refresh Token System
- **accessToken**: 15-minute JWT for API calls
- **refreshToken**: 7-day JWT for token renewal
- **Auto-refresh**: Seamless renewal on 401/403 responses
- **Legacy compatible**: Supports old `token` format
- **Keychain storage**: Secure token persistence

### Smart Photo Caching
- **expiresIn**: Photo URL expiration in seconds
- **format**: Photo format metadata (heic, jpg, etc.)
- **Auto-cleanup**: Expired photo cache invalidation
- **Cache stats**: Debug info with expiration tracking

### Enhanced Pagination
- **hasNext/hasPrev**: Server-provided navigation hints
- **APIMetadata**: Cloudflare optimization flags
- **Fallback logic**: Computed properties for backward compatibility

### Auto-Retry Logic
- **401/403 detection**: Automatic token refresh attempt
- **Request replay**: Seamless retry with fresh token
- **Fallback logout**: Auto-logout if refresh fails
- **Zero interruption**: User doesn't see auth failures

### 🚀 Lightning-Fast Loading ✅ NEW
- **JWT Local Validation**: Instant token expiration check (no API calls)
- **Smart Auto-Refresh**: Only refreshes when needed (2-min buffer)
- **Optimized Startup**: Eliminated artificial delays - app opens instantly
- **Intelligent Flow**: accessToken → refreshToken → logout (only as last resort)

### 🎯 Drag & Drop System ✅ ENHANCED
- **Universal Compatibility**: Finder, browsers, Preview, Fotos, creative apps
- **Smart Detection**: Intelligent type identification with automatic fallback
- **Multi-Format Support**: JPEG, PNG, GIF, HEIC, TIFF + data/URL variants
- **Robust Processing**: Handles NSImage, Data, URL, and String URL formats
- **Error Recovery**: Resolved kDragIPCCompleted issues with improved async handling
- **Debug Logging**: Comprehensive logging for troubleshooting and verification
- **Type Hierarchy**: File URLs → public.image → specific types → fallback search
- **HDR Compatible**: Processes modern HDR images with gain map warnings (non-critical)

## Architecture
- **Pattern**: MVVM with SwiftUI + Combine
- **Security**: JWT + refresh tokens with auto-renewal + local validation
- **Caching**: LRU cache with photo expiration intelligence
- **Networking**: Auto-retry HTTP client with token refresh
- **Performance**: Lightning-fast startup with JWT local validation
- **Compatibility**: 100% backward compatible with legacy APIs

## API Endpoints

### Authentication ✅ CLOUDFLARE-ENHANCED
- `POST /auth/login` - Returns accessToken + refreshToken + user
- `POST /auth/register` - Returns accessToken + refreshToken + user  
- `POST /auth/refresh` - **NEW** Refresh expired access token
- `POST /auth/forgot-password` - Request password reset code
- `POST /auth/verify-reset-code` - Verify code → returns resetToken
- `POST /auth/reset-password` - Reset password with token

### Weight Management
- `POST /weights` - Create weight (multipart with photo)
- `PATCH /weights/:id` - Update weight
- `DELETE /weights/:id` - Delete weight
- `GET /dashboard` - Dashboard data
- `GET /weights/paginated` - Table data (5 per page)
- `GET /weights/chart-data` - Chart data with time filters
- `GET /weights/progress` - Progress photos

## Smart Cache System ✅ CLOUDFLARE-ENHANCED

### Cache Types + Photo Expiration
- **Table Cache**: Paginated weights + photo expiration validation
- **Chart Cache**: Chart data by time range  
- **Progress Cache**: Progress photos + automatic expiration cleanup
- **Photo Expiration**: Based on `expiresIn` metadata from Cloudflare

### Intelligence Features
- **Photo expiration detection**: `photo.isExpired` computed property
- **Auto-cleanup**: `cleanupExpiredPhotoCache()` method
- **Debug stats**: Expired photo tracking in `getCacheStatus()`
- **Smart invalidation**: Removes cache when photos expire
- **LRU management**: 50 items max, 10MB limit

### Cache Behavior  
- **Instant loading**: Shows "INSTANT" in logs for cached data
- **Photo validation**: Checks expiration before serving cached images
- **Memory pressure**: Automatic cleanup on system events
- **CRUD invalidation**: Cache cleared on weight operations

## Build Commands
- Build: `xcodebuild -scheme PesoTracker -configuration Debug build`
- Target: PesoTracker (macOS)
- Window: 1000x700 min, 1200x800 default

## Key Settings
- **Tokens**: accessToken + refreshToken in Keychain
- **Images**: 80% quality, max 1024px, smart expiration
- **Cache**: LRU with photo expiration intelligence  
- **Localization**: Spanish
- **Theme**: Green color scheme

## Code Patterns
- **MVVM**: SwiftUI + Combine + Async/await
- **Security**: JWT refresh tokens with auto-renewal
- **Caching**: Smart invalidation with photo expiration
- **Networking**: Auto-retry with token refresh
- **Threading**: Thread-safe concurrent operations