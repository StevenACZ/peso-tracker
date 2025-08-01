# CLAUDE.md

## Project Overview
PesoTracker is a macOS weight tracking app built with SwiftUI. Features: authentication, weight tracking, goals, photos, charts, and smart caching.

## Key Files

### UI Components
- `Views/Auth/` - Login/Register with AuthViewModel
- `Views/Dashboard/MainDashboardView.swift` - Main dashboard (35% sidebar, 65% content)
- `Views/Dashboard/Components/WeightRecordsView.swift` - Weight table with skeleton loading
- `Views/Dashboard/Modals/AddWeightModal.swift` - Add/edit weights with photos
- `Views/Dashboard/Modals/ViewProgressModal.swift` - Progress photos with lazy loading
- `Views/Dashboard/Components/SettingsDropdown.swift` - Settings with logout

### Services
- `Services/AuthService.swift` - JWT authentication
- `Services/APIService.swift` - HTTP client
- `Services/DashboardService.swift` - Dashboard data + logout
- `Services/WeightService.swift` - Weight CRUD + cache invalidation
- `Services/CacheService.swift` - Smart cache system
- `Services/GoalService.swift` - Goal management

### Models
- `Models/Weight.swift` - Weight data with photos
- `Models/APIResponse.swift` - API responses (includes ProgressResponse)
- `Models/User.swift` - User data
- `Models/Goal.swift` - Goal data

## Build Commands
- Build: `xcodebuild -scheme PesoTracker -configuration Debug build`
- Target: PesoTracker (macOS app)
- Window: 1000x700 min, 1200x800 default

## Architecture
- **Pattern**: MVVM with SwiftUI + Combine
- **Services**: API communication, auth, caching
- **ViewModels**: Business logic and state management
- **Models**: Data structures with Codable support

## API Endpoints
- `POST /weights` - Create weight (multipart with photo)
- `PATCH /weights/:id` - Update weight
- `DELETE /weights/:id` - Delete weight
- `GET /dashboard` - Dashboard data
- `GET /weights/paginated` - Table data (5 per page)
- `GET /weights/chart-data` - Chart data with time filters
- `GET /weights/progress` - Progress photos

## Key Settings
- JWT tokens stored in Keychain
- Images: 80% quality, max 1024px
- Weight precision: 2 decimals
- Spanish localization
- Green color scheme

## Smart Cache System ✅ COMPLETE

### Cache Types
- **Table Cache**: Paginated weight data (`"table_page_X"`)
- **Chart Cache**: Chart data by time range (`"chart_timeRange_page_X"`)
- **Progress Cache**: Progress photos array (single cache entry)

### Cache Behavior
- **First visit**: API call + cache storage
- **Subsequent visits**: Instant loading (shows "INSTANT" in logs)
- **Auto-invalidation**: Cache cleared on weight create/update/delete
- **Memory management**: LRU cleanup (50 items max, 10MB limit)
- **App lifecycle**: Auto-cleanup on termination/memory pressure

### Integration Points
- `DashboardService.loadTableData()` - checks cache before API
- `DashboardService.loadChartData()` - checks cache before API  
- `DashboardService.loadProgressData()` - checks cache before API
- `WeightService` - invalidates cache after CRUD operations
- `DashboardService.logout()` - clears all cache

### Loading States
- **Table**: Professional skeleton loading (5 rows with shimmer animation)
- **Progress**: Lazy image loading with custom `LazyAsyncImage` component
- **Charts**: Standard loading with cache check

## Important Features

### Progress Modal
- Cached progress data for instant loading
- Lazy image loading with `LazyAsyncImage`
- Tap navigation (left/right halves)
- Spanish dates, kg weights
- Progress bar and dots indicator

### Weight Table  
- Professional skeleton loading (shimmer animation)
- Smart pagination with cache
- Edit/delete buttons per row
- Photo indicators

### BMI Calculator
- Medical classifications with colors
- Height/weight/age/gender inputs
- Ideal weight range calculation
- Accessible via settings dropdown

### Goal Management
- Create/edit weight goals
- Date picker integration
- Form validation
- Auto-refresh dashboard

## Code Patterns
- SwiftUI + Combine
- Async/await for API calls
- Spanish localization
- Thread-safe operations
- PlainButtonStyle for buttons
- Green color scheme