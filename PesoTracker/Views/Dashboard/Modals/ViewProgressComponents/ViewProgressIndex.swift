// MARK: - View Progress Components Index
// This file serves as a central reference for all View Progress components

// MARK: - State Management
// ProgressViewState - Enum defining all possible view states
// ProgressDataManager - Centralized data loading logic

// MARK: - State Views
// ProgressLoadingView - Loading state with spinner
// ProgressErrorView - Error state with message and close button
// ProgressEmptyView - Empty state when no photos available

// MARK: - Content Components
// ProgressPhotoViewer - Main photo display with navigation
// ProgressIndicators - Dot indicators for photo navigation
// ProgressWeightInfo - Weight and date information display
// ProgressNotes - Notes/description display
// ProgressBarView - Progress bar with photo counter
// ProgressContentView - Main content container

// MARK: - Reusable Components
// ProgressActionButton - Styled action button

// MARK: - Usage Pattern
/*
 1. Initialize with loading state
 2. Load data asynchronously
 3. Update state based on result:
    - .content(data) if successful and has data
    - .empty if successful but no data
    - .error(message) if failed
 4. UI automatically updates based on state
*/

// MARK: - State Machine Flow
/*
 .loading → .content(data) → User interaction
     ↓           ↓
 .error      .empty
     ↓           ↓
   Close      Close
*/