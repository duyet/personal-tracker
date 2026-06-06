import XCTest
@testable import PersonalTrackerShared

// MARK: - ModelTests

/// Unit tests for data models
final class ModelTests: XCTestCase {
    // MARK: - ActivityRecord Tests

    func test_baseActivity_initialization() {
        // Given
        let timestamp = Date()
        let activity = BaseActivity(
            timestamp: timestamp,
            activityType: .location,
            title: "Test Location"
        )

        // Then
        XCTAssertEqual(activity.activityType, .location)
        XCTAssertEqual(activity.title, "Test Location")
        XCTAssertEqual(activity.timestamp, timestamp)
        XCTAssertFalse(activity.isFavorite)
        XCTAssertEqual(activity.privacyLevel, .privateLevel)
    }

    func test_activityRecord_formattedTimestamp() {
        // Given
        let activity = BaseActivity(
            timestamp: Date(),
            activityType: .location
        )

        // Then
        XCTAssertFalse(activity.formattedTimestamp.isEmpty)
    }

    func test_activityRecord_relativeTimeString() {
        // Given
        let activity = BaseActivity(
            timestamp: Date(),
            activityType: .location
        )

        // Then
        XCTAssertFalse(activity.relativeTimeString.isEmpty)
    }

    func test_activityRecord_isToday() {
        // Given
        let activity = BaseActivity(
            timestamp: Date(),
            activityType: .location
        )

        // Then
        XCTAssertTrue(activity.isToday)
    }

    // MARK: - LocationActivity Tests

    func test_locationActivity_initialization() {
        // Given
        let latitude = 37.7749
        let longitude = -122.4194
        let activity = LocationActivity(
            latitude: latitude,
            longitude: longitude,
            horizontalAccuracy: 10.0,
            placeName: "San Francisco"
        )

        // Then
        XCTAssertEqual(activity.latitude, latitude)
        XCTAssertEqual(activity.longitude, longitude)
        XCTAssertEqual(activity.placeName, "San Francisco")
        XCTAssertEqual(activity.activityType, .location)
    }

    func test_locationActivity_coordinateString() {
        // Given
        let activity = LocationActivity(
            latitude: 37.774900,
            longitude: -122.419400,
            horizontalAccuracy: 10.0
        )

        // Then
        XCTAssertTrue(activity.coordinateString.contains("37.77"))
        XCTAssertTrue(activity.coordinateString.contains("-122.41"))
    }

    func test_locationActivity_distance() {
        // Given
        let location1 = LocationActivity(
            latitude: 37.7749,
            longitude: -122.4194,
            horizontalAccuracy: 10.0
        )

        let location2 = LocationActivity(
            latitude: 37.7849,
            longitude: -122.4094,
            horizontalAccuracy: 10.0
        )

        // When
        let distance = location1.distance(from: location2)

        // Then
        XCTAssertGreaterThan(distance, 0)
    }

    // MARK: - CalendarActivity Tests

    func test_calendarActivity_initialization() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(3600) // 1 hour later
        let activity = CalendarActivity(
            startDate: startDate,
            endDate: endDate,
            calendar: "Work",
            title: "Team Meeting"
        )

        // Then
        XCTAssertEqual(activity.title, "Team Meeting")
        XCTAssertEqual(activity.calendar, "Work")
        XCTAssertEqual(activity.activityType, .calendar)
    }

    func test_calendarActivity_duration() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(3600) // 1 hour
        let activity = CalendarActivity(
            startDate: startDate,
            endDate: endDate,
            calendar: "Work"
        )

        // Then
        XCTAssertEqual(activity.duration, 3600, accuracy: 1)
    }

    func test_calendarActivity_formattedDuration() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(3660) // 1h 1m
        let activity = CalendarActivity(
            startDate: startDate,
            endDate: endDate,
            calendar: "Work"
        )

        // Then
        XCTAssertTrue(activity.formattedDuration.contains("1h"))
    }

    func test_calendarActivity_isHappeningNow() {
        // Given
        let now = Date()
        let startDate = now.addingTimeInterval(-1800) // 30 minutes ago
        let endDate = now.addingTimeInterval(1800) // 30 minutes from now
        let activity = CalendarActivity(
            startDate: startDate,
            endDate: endDate,
            calendar: "Work"
        )

        // Then
        XCTAssertTrue(activity.isHappeningNow)
    }

    // MARK: - MediaActivity Tests

    func test_mediaActivity_initialization() {
        // Given
        let creationDate = Date()
        let activity = MediaActivity(
            mediaType: .photo,
            fileName: "IMG_001.jpg",
            width: 1920,
            height: 1080,
            creationDate: creationDate
        )

        // Then
        XCTAssertEqual(activity.mediaType, .photo)
        XCTAssertEqual(activity.fileName, "IMG_001.jpg")
        XCTAssertEqual(activity.width, 1920)
        XCTAssertEqual(activity.height, 1080)
    }

    func test_mediaActivity_resolution() {
        // Given
        let activity = MediaActivity(
            mediaType: .photo,
            width: 1920,
            height: 1080,
            creationDate: Date()
        )

        // Then
        XCTAssertEqual(activity.resolution, "1920×1080")
    }

    func test_mediaActivity_aspectRatio() {
        // Given
        let activity = MediaActivity(
            mediaType: .photo,
            width: 1920,
            height: 1080,
            creationDate: Date()
        )

        // Then
        XCTAssertEqual(activity.aspectRatio, 16.0 / 9.0, accuracy: 0.01)
    }

    // MARK: - DeviceActivity Tests

    func test_deviceActivity_initialization() {
        // Given
        let activity = DeviceActivity(
            deviceName: "iPhone 15 Pro",
            deviceModel: "iPhone15,2",
            systemName: "iOS",
            systemVersion: "17.0"
        )

        // Then
        XCTAssertEqual(activity.deviceName, "iPhone 15 Pro")
        XCTAssertEqual(activity.systemName, "iOS")
        XCTAssertEqual(activity.activityType, .device)
    }

    func test_deviceActivity_batteryLevel() {
        // Given
        let activity = DeviceActivity(
            deviceName: "iPhone",
            deviceModel: "iPhone",
            systemName: "iOS",
            systemVersion: "17.0",
            batteryLevel: 0.85
        )

        // Then
        XCTAssertEqual(activity.formattedBatteryLevel, "85%")
    }

    func test_deviceActivity_storageUsagePercentage() {
        // Given
        let activity = DeviceActivity(
            deviceName: "iPhone",
            deviceModel: "iPhone",
            systemName: "iOS",
            systemVersion: "17.0",
            storageUsed: 50_000_000_000, // 50GB
            storageTotal: 100_000_000_000 // 100GB
        )

        // Then
        XCTAssertEqual(activity.storageUsagePercentage, 0.5, accuracy: 0.01)
    }
}
