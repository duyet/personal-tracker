import XCTest
@testable import PersonalTrackerShared

// MARK: - ServiceTests

/// Unit tests for service classes
@available(iOS 14.0, macOS 11.0, *)
final class ServiceTests: XCTestCase {
    // MARK: - DataExportService Tests

    func test_exportService_jsonExport() throws {
        // Given
        let service = DataExportService()
        let activities = [
            BaseActivity(
                timestamp: Date(),
                activityType: .location,
                title: "Test Location"
            ),
            BaseActivity(
                timestamp: Date(),
                activityType: .calendar,
                title: "Test Event"
            )
        ]

        // When
        let data = try service.exportToJSON(activities)

        // Then
        XCTAssertFalse(data.isEmpty)

        // Verify it's valid JSON
        let decoded = try JSONDecoder().decode([BaseActivity].self, from: data)
        XCTAssertEqual(decoded.count, activities.count)
    }

    func test_exportService_csvExport() throws {
        // Given
        let service = DataExportService()
        let activities: [any ActivityRecord] = [
            BaseActivity(
                timestamp: Date(),
                activityType: .location,
                title: "Test Location"
            )
        ]

        // When
        let data = try service.exportToCSV(activities)

        // Then
        XCTAssertFalse(data.isEmpty)

        // Verify CSV structure
        let csvString = String(data: data, encoding: .utf8)
        XCTAssertNotNil(csvString)
        XCTAssertTrue(csvString!.contains("ID,Timestamp,Type"))
    }

    func test_exportService_escapeCSVField() throws {
        // Given
        let service = DataExportService()
        let activities: [any ActivityRecord] = [
            BaseActivity(
                timestamp: Date(),
                activityType: .location,
                title: "Test, with, commas"
            )
        ]

        // When
        let data = try service.exportToCSV(activities)
        let csvString = String(data: data, encoding: .utf8)

        // Then
        XCTAssertNotNil(csvString)
        XCTAssertTrue(csvString!.contains("\"Test, with, commas\""))
    }

    func test_exportService_locationCSVExport() throws {
        // Given
        let service = DataExportService()
        let activities = [
            LocationActivity(
                latitude: 37.7749,
                longitude: -122.4194,
                horizontalAccuracy: 10.0,
                placeName: "San Francisco"
            )
        ]

        // When
        let data = try service.exportLocationActivitiesToCSV(activities)

        // Then
        XCTAssertFalse(data.isEmpty)

        let csvString = String(data: data, encoding: .utf8)
        XCTAssertNotNil(csvString)
        XCTAssertTrue(csvString!.contains("Latitude,Longitude"))
        XCTAssertTrue(csvString!.contains("37.774900"))
    }

    func test_exportService_getExportSummary() {
        // Given
        let service = DataExportService()
        let activities = [
            BaseActivity(
                timestamp: Date(),
                activityType: .location,
                title: "Test"
            )
        ]

        // When
        let summary = service.getExportSummary(for: activities, format: .json)

        // Then
        XCTAssertEqual(summary.itemCount, 1)
        XCTAssertEqual(summary.formatName, "JSON")
        XCTAssertGreaterThan(summary.estimatedSize, 0)
    }

    // MARK: - CalendarStatistics Tests

    func test_calendarStatistics_calculate() {
        // Given
        let now = Date()
        let startDate = now.addingTimeInterval(-3600)
        let endDate = now.addingTimeInterval(3600)

        let activities = [
            CalendarActivity(
                startDate: startDate,
                endDate: now,
                calendar: "Work",
                title: "Past Event"
            ),
            CalendarActivity(
                startDate: now,
                endDate: endDate,
                calendar: "Personal",
                title: "Future Event"
            )
        ]

        // When
        let stats = CalendarStatistics.calculate(from: activities)

        // Then
        XCTAssertEqual(stats.totalEvents, 2)
        XCTAssertEqual(stats.upcomingEvents, 1)
        XCTAssertEqual(stats.pastEvents, 1)
        XCTAssertGreaterThan(stats.totalDuration, 0)
        XCTAssertGreaterThan(stats.averageDuration, 0)
    }

    func test_calendarStatistics_longestEvent() {
        // Given
        let now = Date()
        let activities = [
            CalendarActivity(
                startDate: now,
                endDate: now.addingTimeInterval(1800), // 30 min
                calendar: "Work"
            ),
            CalendarActivity(
                startDate: now,
                endDate: now.addingTimeInterval(7200), // 2 hours
                calendar: "Work"
            )
        ]

        // When
        let stats = CalendarStatistics.calculate(from: activities)

        // Then
        XCTAssertNotNil(stats.longestEvent)
        XCTAssertEqual(stats.longestEvent?.duration, 7200, accuracy: 1)
    }

    // MARK: - MediaStatistics Tests

    func test_mediaStatistics_calculate() {
        // Given
        let activities = [
            MediaActivity(
                mediaType: .photo,
                fileSize: 1_000_000,
                width: 1920,
                height: 1080,
                creationDate: Date()
            ),
            MediaActivity(
                mediaType: .video,
                fileSize: 10_000_000,
                duration: 60,
                creationDate: Date()
            )
        ]

        // When
        let stats = MediaStatistics.calculate(from: activities)

        // Then
        XCTAssertEqual(stats.totalMedia, 2)
        XCTAssertEqual(stats.totalPhotos, 1)
        XCTAssertEqual(stats.totalVideos, 1)
        XCTAssertEqual(stats.totalSize, 11_000_000)
        XCTAssertEqual(stats.averageSize, 5_500_000)
        XCTAssertEqual(stats.totalVideoDuration, 60, accuracy: 1)
    }

    func test_mediaStatistics_locationPercentage() {
        // Given
        let coord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let activities = [
            MediaActivity(
                mediaType: .photo,
                location: coord,
                creationDate: Date()
            ),
            MediaActivity(
                mediaType: .photo,
                creationDate: Date()
            )
        ]

        // When
        let stats = MediaStatistics.calculate(from: activities)

        // Then
        XCTAssertEqual(stats.mediaWithLocation, 1)
        XCTAssertEqual(stats.locationPercentage, 0.5, accuracy: 0.01)
    }

    // MARK: - CallStatistics Tests

    func test_callStatistics_calculate() {
        // Given
        let activities = [
            CallActivity(
                callType: .voice,
                direction: .incoming,
                phoneNumber: "+1234567890",
                duration: 300,
                wasAnswered: true
            ),
            CallActivity(
                callType: .voice,
                direction: .incoming,
                phoneNumber: "+1234567890",
                duration: 0,
                wasAnswered: false
            ),
            CallActivity(
                callType: .voice,
                direction: .outgoing,
                phoneNumber: "+0987654321",
                duration: 600
            )
        ]

        // When
        let stats = CallStatistics.calculate(from: activities)

        // Then
        XCTAssertEqual(stats.totalCalls, 3)
        XCTAssertEqual(stats.incomingCalls, 2)
        XCTAssertEqual(stats.outgoingCalls, 1)
        XCTAssertEqual(stats.missedCalls, 1)
        XCTAssertEqual(stats.totalDuration, 900, accuracy: 1)
        XCTAssertGreaterThan(stats.averageDuration, 0)
    }

    func test_callStatistics_missedCallRate() {
        // Given
        let activities = [
            CallActivity(
                callType: .voice,
                direction: .incoming,
                duration: 300,
                wasAnswered: true
            ),
            CallActivity(
                callType: .voice,
                direction: .incoming,
                duration: 0,
                wasAnswered: false
            ),
            CallActivity(
                callType: .voice,
                direction: .incoming,
                duration: 0,
                wasAnswered: false
            ),
            CallActivity(
                callType: .voice,
                direction: .incoming,
                duration: 0,
                wasAnswered: false
            )
        ]

        // When
        let stats = CallStatistics.calculate(from: activities)

        // Then
        XCTAssertEqual(stats.missedCallRate, 0.75, accuracy: 0.01)
    }

    // MARK: - DeviceStatistics Tests

    func test_deviceStatistics_calculate() {
        // Given
        let activities = [
            DeviceActivity(
                deviceName: "iPhone",
                deviceModel: "iPhone15,2",
                systemName: "iOS",
                systemVersion: "17.0",
                batteryLevel: 0.8
            ),
            DeviceActivity(
                deviceName: "iPhone",
                deviceModel: "iPhone15,2",
                systemName: "iOS",
                systemVersion: "17.0",
                batteryLevel: 0.6
            )
        ]

        // When
        let stats = DeviceStatistics.calculate(from: activities)

        // Then
        XCTAssertEqual(stats.totalSnapshots, 2)
        XCTAssertEqual(stats.averageBatteryLevel, 0.7, accuracy: 0.01)
        XCTAssertEqual(stats.lowestBatteryLevel, 0.6, accuracy: 0.01)
        XCTAssertEqual(stats.highestBatteryLevel, 0.8, accuracy: 0.01)
    }
}
