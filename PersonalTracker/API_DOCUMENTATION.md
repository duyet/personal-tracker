# Personal Tracker API Documentation

## Overview

This document provides comprehensive API documentation for Personal Tracker's core components, services, and models.

## Table of Contents

1. [Models](#models)
2. [Services](#services)
3. [ViewModels](#viewmodels)
4. [Utilities](#utilities)

---

## Models

### ActivityRecord Protocol

Base protocol that all activity types conform to.

```swift
protocol ActivityRecord: Identifiable, Codable {
    var id: UUID { get }
    var timestamp: Date { get }
    var activityType: ActivityType { get }
    var title: String? { get set }
    var notes: String? { get set }
    var tags: [String] { get set }
    var isFavorite: Bool { get set }
    var privacyLevel: PrivacyLevel { get set }
    var metadata: [String: String] { get set }
}
```

**Properties:**
- `id`: Unique identifier for the activity
- `timestamp`: When the activity occurred
- `activityType`: Type of activity (location, calendar, media, etc.)
- `title`: Optional title for the activity
- `notes`: Optional notes/description
- `tags`: Array of tags for categorization
- `isFavorite`: Whether the activity is marked as favorite
- `privacyLevel`: Privacy level (public, private, sensitive)
- `metadata`: Additional key-value metadata

### LocationActivity

Represents a location-based activity.

```swift
struct LocationActivity: ActivityRecord {
    let latitude: Double
    let longitude: Double
    let altitude: Double?
    let horizontalAccuracy: Double
    let verticalAccuracy: Double?
    let speed: Double?
    let course: Double?
    let address: String?
    let placeName: String?
    let category: LocationCategory
}
```

**Properties:**
- `latitude`: Latitude in degrees (-90 to 90)
- `longitude`: Longitude in degrees (-180 to 180)
- `altitude`: Altitude in meters (optional)
- `horizontalAccuracy`: Horizontal accuracy in meters
- `verticalAccuracy`: Vertical accuracy in meters (optional)
- `speed`: Speed in meters per second (optional)
- `course`: Direction in degrees (0-360, optional)
- `address`: Reverse-geocoded address (optional)
- `placeName`: Named place (optional)
- `category`: Location category (home, work, travel, etc.)

**Computed Properties:**
- `coordinate: CLLocationCoordinate2D` - CoreLocation coordinate
- `hasValidCoordinate: Bool` - Whether coordinate is valid
- `formattedSpeed: String?` - Speed formatted as "X m/s" or "X km/h"
- `formattedCourse: String?` - Course formatted as "N", "NE", "E", etc.

**Example:**

```swift
let location = LocationActivity(
    latitude: 37.7749,
    longitude: -122.4194,
    horizontalAccuracy: 10.0,
    category: .home
)

print(location.coordinate) // CLLocationCoordinate2D
print(location.formattedSpeed) // "5.2 m/s"
```

### CalendarActivity

Represents a calendar event.

```swift
struct CalendarActivity: ActivityRecord {
    let eventIdentifier: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let location: String?
    let calendar: String?
    let attendees: [String]
    let organizer: String?
    let url: URL?
    let eventType: EventType
    let status: EventStatus
    let recurrenceRule: String?
}
```

**Computed Properties:**
- `duration: TimeInterval` - Event duration in seconds
- `formattedDuration: String` - Duration formatted as "2h 30m"
- `isUpcoming: Bool` - Whether event is in the future
- `isPast: Bool` - Whether event is in the past
- `isOngoing: Bool` - Whether event is currently happening

### MediaActivity

Represents a photo or video.

```swift
struct MediaActivity: ActivityRecord {
    let assetIdentifier: String?
    let mediaType: MediaType
    let fileName: String?
    let fileSize: Int64?
    let width: Int?
    let height: Int?
    let duration: TimeInterval?
    let location: CLLocationCoordinate2D?
    let creationDate: Date
    let modificationDate: Date?
    let albumName: String?
    let isFavoriteInPhotos: Bool
    let isHidden: Bool
    let source: MediaSource
}
```

**Computed Properties:**
- `formattedFileSize: String?` - File size formatted as "2.5 MB"
- `resolution: String?` - Resolution formatted as "1920×1080"
- `aspectRatio: Double?` - Aspect ratio (width/height)
- `hasLocation: Bool` - Whether media has location data
- `formattedDuration: String?` - Duration formatted as "2:34"

### URLActivity

Represents a website visit.

```swift
struct URLActivity: ActivityRecord {
    let url: URL
    let pageTitle: String?
    let domain: String
    let scheme: String?
    let visitCount: Int
    let lastVisitDate: Date
    let isBookmarked: Bool
    let source: BrowserSource
    let referrer: URL?
    let duration: TimeInterval?
}
```

**Computed Properties:**
- `urlString: String` - Full URL string
- `displayURL: String` - URL without scheme
- `isSecure: Bool` - Whether using HTTPS
- `isRecentlyVisited: Bool` - Visited within last hour
- `isFrequentlyVisited: Bool` - Visit count >= 5
- `faviconURL: URL?` - Favicon URL

### CallActivity

Represents a phone call (iOS only).

```swift
struct CallActivity: ActivityRecord {
    let callType: CallType
    let direction: CallDirection
    let phoneNumber: String?
    let contactName: String?
    let duration: TimeInterval
    let wasAnswered: Bool
    let wasBlocked: Bool
    let carrierName: String?
    let callIdentifier: String
}
```

### DeviceActivity

Represents device status snapshot.

```swift
struct DeviceActivity: ActivityRecord {
    let deviceName: String
    let deviceModel: String
    let deviceIdentifier: String
    let systemName: String
    let systemVersion: String
    let batteryLevel: Float
    let batteryState: BatteryState
    let storageUsed: Int64
    let storageTotal: Int64
    let memoryUsed: Int64
    let memoryTotal: Int64
    let isLowPowerMode: Bool
    let screenBrightness: Double
    let deviceOrientation: DeviceOrientation
    let networkType: NetworkType
}
```

### AdTrackingActivity

Represents ad tracking transparency status.

```swift
struct AdTrackingActivity: ActivityRecord {
    let trackingStatus: TrackingStatus
    let advertisingIdentifier: String?
    let isLimitAdTrackingEnabled: Bool
    let trackingDomains: [String]
    let blockedTrackers: Int
    let allowedTrackers: Int
}
```

**Computed Properties:**
- `totalTrackers: Int` - Total trackers detected
- `blockedPercentage: Double` - Percentage of blocked trackers
- `formattedBlockedPercentage: String` - Formatted as "75.0%"
- `isTrackingAuthorized: Bool` - Whether tracking is authorized
- `privacyProtectionLevel: PrivacyProtectionLevel` - High/Medium/Low

---

## Services

### LocationTrackingService

Manages location tracking with privacy controls.

```swift
class LocationTrackingService {
    static let shared: LocationTrackingService
    
    func startTracking()
    func stopTracking()
    func requestPermission() async -> Bool
    func getCurrentLocation() async throws -> LocationActivity
}
```

**Methods:**

**`startTracking()`**
- Starts continuous location tracking
- Requires location permission
- Posts notifications on location updates

**`stopTracking()`**
- Stops location tracking
- Saves battery

**`requestPermission() async -> Bool`**
- Requests location permission from user
- Returns `true` if granted, `false` otherwise

**`getCurrentLocation() async throws -> LocationActivity`**
- Gets single location update
- Throws error if permission denied or location unavailable

**Example:**

```swift
let service = LocationTrackingService.shared

// Request permission
let granted = await service.requestPermission()
guard granted else { return }

// Start tracking
service.startTracking()

// Get current location
do {
    let location = try await service.getCurrentLocation()
    print("Latitude: \(location.latitude)")
} catch {
    print("Error: \(error)")
}
```

### CalendarService

Manages calendar event tracking.

```swift
class CalendarService {
    static let shared: CalendarService
    
    func requestPermission() async -> Bool
    func fetchEvents(from: Date, to: Date) async throws -> [CalendarActivity]
    func observeCalendarChanges()
}
```

### MediaTrackingService

Manages photo library tracking.

```swift
class MediaTrackingService {
    static let shared: MediaTrackingService
    
    func requestPermission() async -> Bool
    func fetchRecentMedia(limit: Int) async throws -> [MediaActivity]
    func observePhotoLibraryChanges()
}
```

### DeviceInfoService

Collects device information.

```swift
class DeviceInfoService {
    static let shared: DeviceInfoService
    
    func getCurrentDeviceInfo() -> DeviceActivity
    func startMonitoring()
    func stopMonitoring()
}
```

### DataExportService

Handles data export functionality.

```swift
class DataExportService {
    enum ExportFormat {
        case json
        case csv
    }
    
    func exportData<T: Encodable>(
        activities: [T],
        format: ExportFormat
    ) async throws -> URL
    
    func getExportSummary<T: Encodable>(
        for activities: [T],
        format: ExportFormat
    ) -> ExportSummary
}
```

**Example:**

```swift
let service = DataExportService()
let activities: [LocationActivity] = [/* ... */]

// Export to JSON
do {
    let url = try await service.exportData(
        activities: activities,
        format: .json
    )
    print("Exported to: \(url)")
} catch {
    print("Export failed: \(error)")
}
```

### PrivacyService

Centralized privacy and permission management.

```swift
class PrivacyService {
    static let shared: PrivacyService
    
    func checkPermission(for type: PermissionType) -> PermissionStatus
    func requestPermission(for type: PermissionType) async -> Bool
    func openSettings()
}
```

---

## ViewModels

### DashboardViewModel

Manages dashboard state.

```swift
@MainActor
class DashboardViewModel: ObservableObject {
    @Published var locationActivities: [LocationActivity]
    @Published var calendarActivities: [CalendarActivity]
    @Published var mediaActivities: [MediaActivity]
    @Published var deviceActivities: [DeviceActivity]
    @Published var isLoading: Bool
    
    func loadActivities() async
    func refreshData() async
}
```

### SettingsViewModel

Manages app settings.

```swift
@MainActor
class SettingsViewModel: ObservableObject {
    @Published var privacySettings: PrivacySettings
    @Published var isExporting: Bool
    
    func toggleSetting(_ keyPath: WritableKeyPath<PrivacySettings, Bool>)
    func exportData(
        activities: [any ActivityRecord],
        format: DataExportService.ExportFormat
    ) async throws -> URL
}
```

---

## Utilities

### Logger

Structured logging utility.

```swift
enum Logger {
    static let location: OSLog
    static let calendar: OSLog
    static let media: OSLog
    static let network: OSLog
    static let ui: OSLog
}

// Usage
Logger.location.info("Started location tracking")
Logger.location.error("Failed to get location: \(error)")
```

### Localization (L10n)

Type-safe localization.

```swift
// Usage
Text(L10n.Dashboard.title)
Text(L10n.Permission.locationDescription)
Text(L10n.Button.export)
```

---

## Error Handling

### Standard Error Types

```swift
enum TrackingError: Error {
    case permissionDenied
    case locationUnavailable
    case networkError
    case invalidData
}
```

**Example:**

```swift
do {
    let location = try await service.getCurrentLocation()
    // Handle location
} catch TrackingError.permissionDenied {
    // Show permission prompt
} catch TrackingError.locationUnavailable {
    // Show error message
} catch {
    // Handle unknown error
}
```

---

## Best Practices

### Memory Management

```swift
// ✅ Use weak/unowned for closures
service.onLocationUpdate = { [weak self] location in
    self?.handleLocation(location)
}

// ✅ Cancel subscriptions
private var cancellables = Set<AnyCancellable>()

deinit {
    cancellables.removeAll()
}
```

### Async/Await

```swift
// ✅ Use async/await for asynchronous operations
func loadData() async {
    do {
        let data = try await fetchData()
        await MainActor.run {
            self.updateUI(with: data)
        }
    } catch {
        // Handle error
    }
}
```

### SwiftUI Integration

```swift
// ✅ Use @StateObject for ownership
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        // UI code
    }
}

// ✅ Use @ObservedObject for passed objects
struct DetailView: View {
    @ObservedObject var viewModel: DashboardViewModel
}
```

---

## Testing

### Unit Testing Models

```swift
func testLocationActivity() {
    let activity = LocationActivity(
        latitude: 37.7749,
        longitude: -122.4194,
        horizontalAccuracy: 10.0,
        category: .home
    )
    
    XCTAssertNotNil(activity.id)
    XCTAssertEqual(activity.latitude, 37.7749)
    XCTAssertTrue(activity.hasValidCoordinate)
}
```

### Testing Services

```swift
func testLocationService() async {
    let service = LocationTrackingService.shared
    let granted = await service.requestPermission()
    
    if granted {
        let location = try? await service.getCurrentLocation()
        XCTAssertNotNil(location)
    }
}
```

---

## Changelog

### Version 1.0.0 (2025-11-17)

- Initial API documentation
- Core models and services
- ViewModels for UI state
- Utilities and helpers

---

**For Questions:** See [CONTRIBUTING.md](CONTRIBUTING.md) or open an issue on GitHub.
