# Personal Tracker - Architecture Documentation

## Overview

Personal Tracker is a privacy-first iOS and macOS application built using modern Swift and SwiftUI. This document provides an in-depth technical overview of the system architecture, design patterns, and implementation details.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  iOS Views   │  │ macOS Views  │  │   Widgets    │          │
│  │   (SwiftUI)  │  │  (SwiftUI)   │  │  (SwiftUI)   │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
└─────────┼──────────────────┼──────────────────┼─────────────────┘
          │                  │                  │
┌─────────┼──────────────────┼──────────────────┼─────────────────┐
│         │          ViewModel Layer            │                 │
│  ┌──────▼────────────────────────────────────▼───────┐          │
│  │  DashboardViewModel  │  SettingsViewModel │ ...   │          │
│  │  (ObservableObject)  │  (ObservableObject) │       │          │
│  └──────┬────────────────┬───────────────────────────┘          │
└─────────┼────────────────┼──────────────────────────────────────┘
          │                │
┌─────────┼────────────────┼──────────────────────────────────────┐
│         │       Service Layer                │                  │
│  ┌──────▼────────────────▼─────────────────────────────┐        │
│  │ LocationService │ CalendarService │ MediaService │...│        │
│  │  (Singleton)    │   (Singleton)   │  (Singleton) │   │        │
│  └──────┬──────────────────┬───────────────────┬──────┘        │
└─────────┼──────────────────┼────────────────────┼───────────────┘
          │                  │                    │
┌─────────┼──────────────────┼────────────────────┼───────────────┐
│         │         Data & System Layer           │               │
│  ┌──────▼──────┐  ┌────────▼─────┐  ┌──────────▼──────┐        │
│  │  CoreData   │  │   CloudKit   │  │  System APIs    │        │
│  │  (Local)    │  │   (Sync)     │  │  (CoreLocation) │        │
│  └─────────────┘  └──────────────┘  └─────────────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

## Core Design Patterns

### 1. MVVM (Model-View-ViewModel)

**Why MVVM?**
- Clear separation of concerns
- Testability (ViewModels can be tested without UI)
- Reactive data flow with Combine
- SwiftUI's natural fit with MVVM

**Implementation:**

```swift
// Model
struct LocationActivity: ActivityRecord {
    let id: UUID
    let timestamp: Date
    // ... properties
}

// ViewModel
class DashboardViewModel: ObservableObject {
    @Published var locationActivities: [LocationActivity] = []
    
    private let locationService: LocationTrackingService
    
    func loadActivities() {
        // Business logic here
    }
}

// View
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        // UI here
    }
}
```

### 2. Protocol-Oriented Design

**ActivityRecord Protocol:**

All activity types conform to the `ActivityRecord` protocol, enabling:
- Polymorphic collections
- Generic algorithms
- Type-safe operations
- Flexible extensibility

```swift
protocol ActivityRecord: Identifiable, Codable {
    var id: UUID { get }
    var timestamp: Date { get }
    var activityType: ActivityType { get }
    var title: String? { get }
    var privacyLevel: PrivacyLevel { get }
    // ... common properties
}
```

### 3. Dependency Injection

Services are injected into ViewModels for:
- Testability (mock services in tests)
- Flexibility (swap implementations)
- Loose coupling

```swift
class DashboardViewModel: ObservableObject {
    private let locationService: LocationTrackingService
    private let calendarService: CalendarService
    
    init(
        locationService: LocationTrackingService = .shared,
        calendarService: CalendarService = .shared
    ) {
        self.locationService = locationService
        self.calendarService = calendarService
    }
}
```

### 4. Singleton Pattern (Services)

Services use the singleton pattern because:
- Single source of truth for permissions
- Shared state across app
- Resource management (location manager, etc.)

```swift
class LocationTrackingService {
    static let shared = LocationTrackingService()
    private init() { }
    
    private let locationManager = CLLocationManager()
    // ...
}
```

## Module Organization

### PersonalTrackerShared

Shared code between iOS and macOS:

```
PersonalTrackerShared/
├── Models/              # Data models
│   ├── ActivityRecord.swift
│   ├── LocationActivity.swift
│   ├── CalendarActivity.swift
│   └── ...
├── Services/            # Business logic
│   ├── LocationTrackingService.swift
│   ├── CalendarService.swift
│   └── ...
├── ViewModels/          # View state management
│   ├── DashboardViewModel.swift
│   └── SettingsViewModel.swift
└── Utilities/           # Helper code
    ├── Logger.swift
    └── Extensions.swift
```

### PersonalTracker (iOS)

iOS-specific code:

```
PersonalTracker/
├── App/
│   └── PersonalTrackerApp.swift
├── Views/
│   ├── DashboardView.swift
│   ├── ActivityListView.swift
│   └── ...
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

### PersonalTrackerMac (macOS)

macOS-specific code:

```
PersonalTrackerMac/
├── App/
│   └── PersonalTrackerMacApp.swift
├── Views/
│   ├── MacDashboardView.swift
│   ├── MacActivityListView.swift
│   └── ...
└── Resources/
    └── Info.plist
```

## Data Flow

### 1. Location Tracking Flow

```
User enables location tracking
    ↓
PrivacyService checks permission
    ↓
LocationTrackingService requests authorization
    ↓
CLLocationManager delivers updates
    ↓
LocationTrackingService processes locations
    ↓
LocationActivity created
    ↓
Stored in CoreData
    ↓
DashboardViewModel updates @Published properties
    ↓
SwiftUI view automatically updates
```

### 2. Settings Update Flow

```
User toggles setting in UI
    ↓
SettingsViewModel receives input
    ↓
PrivacySettings model updated
    ↓
Changes persisted to UserDefaults
    ↓
Notification posted (if needed)
    ↓
Relevant services observe changes
    ↓
Services start/stop tracking accordingly
```

### 3. Export Flow

```
User requests export
    ↓
SettingsViewModel calls DataExportService
    ↓
Activities fetched from CoreData
    ↓
DataExportService serializes to JSON/CSV
    ↓
File written to temporary directory
    ↓
Share sheet presented to user
    ↓
User chooses destination
```

## Concurrency Model

### Async/Await

Modern Swift concurrency for asynchronous operations:

```swift
func exportData(
    activities: [any ActivityRecord],
    format: ExportFormat
) async throws -> URL {
    // Async work here
}
```

### Main Actor

UI updates on main thread:

```swift
@MainActor
class DashboardViewModel: ObservableObject {
    @Published var activities: [LocationActivity] = []
    
    func loadActivities() async {
        // Safe to update @Published properties
    }
}
```

### Background Processing

Long-running tasks on background threads:

```swift
Task.detached {
    // Heavy computation
    let result = await processData()
    
    await MainActor.run {
        // Update UI
    }
}
```

## State Management

### SwiftUI Property Wrappers

```swift
// App-level state
@StateObject var viewModel = DashboardViewModel()

// Passed down state
@ObservedObject var viewModel: DashboardViewModel

// Environment-shared state
@EnvironmentObject var settings: SettingsViewModel

// Local view state
@State private var isShowingSheet = false
```

### Combine Publishers

```swift
class DashboardViewModel: ObservableObject {
    @Published var activities: [LocationActivity] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Reactive transformations
    }
}
```

## Privacy Architecture

### Permission Management

```swift
class PrivacyService {
    enum Permission {
        case location
        case calendar
        case photos
        case contacts
    }
    
    func requestPermission(_ permission: Permission) async -> Bool {
        // Centralized permission handling
    }
}
```

### Data Protection

1. **Encryption at Rest**
   - File protection: `NSFileProtectionComplete`
   - Keychain for sensitive data
   - Secure enclave for biometrics

2. **Privacy Levels**
   ```swift
   enum PrivacyLevel: String, Codable {
       case publicLevel    // Shareable
       case privateLevel   // Local only
       case sensitive      // Extra protection
   }
   ```

3. **Data Minimization**
   - Only collect what's necessary
   - User controls for each data type
   - Automatic data retention policies

## Performance Optimizations

### 1. Lazy Loading

```swift
ScrollView {
    LazyVStack {
        ForEach(activities) { activity in
            ActivityRow(activity: activity)
        }
    }
}
```

### 2. CoreData Batch Operations

```swift
let fetchRequest = LocationActivity.fetchRequest()
fetchRequest.fetchLimit = 100
fetchRequest.fetchOffset = offset
```

### 3. Image Caching

```swift
// AsyncImage with caching
AsyncImage(url: imageURL) { phase in
    // Handle phases
}
```

### 4. Background Processing

```swift
import BackgroundTasks

BGTaskScheduler.shared.register(
    forTaskWithIdentifier: "com.personaltracker.refresh",
    using: nil
) { task in
    // Background work
}
```

## Testing Strategy

### Unit Tests

```swift
class LocationActivityTests: XCTestCase {
    func testActivityCreation() {
        let activity = LocationActivity(
            latitude: 37.7749,
            longitude: -122.4194
        )
        XCTAssertNotNil(activity.id)
        XCTAssertEqual(activity.latitude, 37.7749)
    }
}
```

### ViewModel Tests

```swift
class DashboardViewModelTests: XCTestCase {
    var viewModel: DashboardViewModel!
    var mockLocationService: MockLocationService!
    
    override func setUp() {
        mockLocationService = MockLocationService()
        viewModel = DashboardViewModel(
            locationService: mockLocationService
        )
    }
    
    func testLoadActivities() async {
        await viewModel.loadActivities()
        XCTAssertFalse(viewModel.activities.isEmpty)
    }
}
```

## Security Considerations

### Input Validation

```swift
func validateInput(_ input: String) -> Bool {
    // Sanitize user input
    let allowedCharacters = CharacterSet.alphanumerics
    return input.rangeOfCharacter(from: allowedCharacters.inverted) == nil
}
```

### No Force Unwrapping

```swift
// ❌ Bad
let value = dictionary["key"]!

// ✅ Good
guard let value = dictionary["key"] else {
    return
}
```

### Keychain Storage

```swift
import Security

func storeInKeychain(key: String, data: Data) -> Bool {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecValueData as String: data,
        kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ]
    return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
}
```

## Future Architecture Considerations

### CoreData Stack

```swift
class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "PersonalTracker")
        container.loadPersistentStores { description, error in
            // Handle errors
        }
    }
}
```

### CloudKit Sync

```swift
class CloudSyncService {
    private let container = CKContainer.default()
    
    func syncActivities() async throws {
        // Sync logic
    }
    
    func resolveConflicts() {
        // Conflict resolution
    }
}
```

### Widget Support

```swift
struct ActivityWidget: Widget {
    let kind: String = "ActivityWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: ActivityProvider()
        ) { entry in
            ActivityWidgetView(entry: entry)
        }
    }
}
```

## Code Quality Tools

### SwiftLint

Configuration enforces:
- Maximum file/function length
- Naming conventions
- Complexity limits
- Force unwrap warnings

### SwiftFormat

Automatic formatting for:
- Indentation (4 spaces)
- Line length (120 characters)
- Brace placement
- Import organization

## Build & Deployment

### GitHub Actions CI/CD

```yaml
jobs:
  build:
    - Checkout code
    - Install dependencies
    - Run SwiftLint
    - Run SwiftFormat check
    - Build project
    - Run tests
    - Archive for distribution
```

### Code Signing

```xml
<!-- Entitlements -->
<key>com.apple.developer.icloud-container-identifiers</key>
<key>com.apple.security.application-groups</key>
<key>keychain-access-groups</key>
```

## Monitoring & Analytics

### Privacy-Preserving Analytics

```swift
// Local-only analytics
class AnalyticsService {
    func trackEvent(_ event: String) {
        // Store locally, never transmit
        Logger.analytics.info("Event: \(event)")
    }
}
```

### Performance Monitoring

```swift
import os.signpost

let log = OSLog(subsystem: "com.personaltracker", category: "performance")

os_signpost(.begin, log: log, name: "Load Activities")
// Work
os_signpost(.end, log: log, name: "Load Activities")
```

## Accessibility

### VoiceOver Support

```swift
Text("Location Activity")
    .accessibilityLabel("Location activity from San Francisco")
    .accessibilityHint("Double tap to view details")
```

### Dynamic Type

```swift
Text("Title")
    .font(.title)  // Automatically scales
```

## Localization

```swift
// Localizable.strings
"location.tracking.enabled" = "Location Tracking Enabled";

// Usage
Text("location.tracking.enabled")
```

---

**Document Version**: 1.0.0  
**Last Updated**: 2025-11-17  
**Maintainer**: Personal Tracker Team

*This is a living document. Please update as the architecture evolves.*
