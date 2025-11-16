import Foundation
import Combine
import SwiftUI

// MARK: - DashboardViewModel

/// ViewModel for the main dashboard view
@available(iOS 14.0, macOS 11.0, *)
@MainActor
final class DashboardViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var selectedTab: ActivityType = .location
    @Published var selectedDate: Date = Date()
    @Published var locationActivities: [LocationActivity] = []
    @Published var calendarActivities: [CalendarActivity] = []
    @Published var mediaActivities: [MediaActivity] = []
    @Published var deviceActivities: [DeviceActivity] = []
    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - Services

    private let locationService: LocationTrackingService
    private let calendarService: CalendarService
    private let mediaService: MediaTrackingService
    private let deviceService: DeviceInfoService

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private let logger = AppLogger.ui

    // MARK: - Initialization

    init(
        locationService: LocationTrackingService = LocationTrackingService(),
        calendarService: CalendarService = CalendarService(),
        mediaService: MediaTrackingService = MediaTrackingService(),
        deviceService: DeviceInfoService = DeviceInfoService()
    ) {
        self.locationService = locationService
        self.calendarService = calendarService
        self.mediaService = mediaService
        self.deviceService = deviceService

        setupObservers()
        loadInitialData()
    }

    // MARK: - Public Methods

    /// Refresh all data
    func refresh() {
        logger.info("Refreshing dashboard data")
        isLoading = true

        Task {
            await refreshLocationActivities()
            await refreshCalendarActivities()
            await refreshMediaActivities()
            await refreshDeviceActivities()

            await MainActor.run {
                isLoading = false
            }
        }
    }

    /// Load activities for selected date
    func loadActivitiesForDate(_ date: Date) {
        logger.info("Loading activities for date: \(date)")
        selectedDate = date

        // Filter activities by selected date
        filterActivitiesByDate()
    }

    /// Get summary statistics
    func getSummary() -> DashboardSummary {
        DashboardSummary(
            totalLocations: locationActivities.count,
            totalEvents: calendarActivities.count,
            totalMedia: mediaActivities.count,
            lastUpdate: Date()
        )
    }

    /// Start tracking for selected activity type
    func startTracking(for type: ActivityType) {
        logger.info("Starting tracking for: \(type.displayName)")

        switch type {
        case .location:
            locationService.startTracking()
        case .device:
            deviceService.startMonitoring()
        default:
            logger.warning("Tracking not supported for: \(type.displayName)")
        }
    }

    /// Stop tracking for selected activity type
    func stopTracking(for type: ActivityType) {
        logger.info("Stopping tracking for: \(type.displayName)")

        switch type {
        case .location:
            locationService.stopTracking()
        case .device:
            deviceService.stopMonitoring()
        default:
            break
        }
    }

    // MARK: - Private Methods

    private func setupObservers() {
        // Observe location activities
        locationService.$activities
            .receive(on: DispatchQueue.main)
            .assign(to: &$locationActivities)

        // Observe calendar activities
        calendarService.$activities
            .receive(on: DispatchQueue.main)
            .assign(to: &$calendarActivities)

        // Observe media activities
        mediaService.$activities
            .receive(on: DispatchQueue.main)
            .assign(to: &$mediaActivities)

        // Observe device activities
        deviceService.$activities
            .receive(on: DispatchQueue.main)
            .assign(to: &$deviceActivities)

        // Observe errors
        locationService.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.error = error
            }
            .store(in: &cancellables)
    }

    private func loadInitialData() {
        logger.info("Loading initial dashboard data")

        // Load recent calendar events
        calendarService.fetchThisWeekEvents()

        // Load recent media
        mediaService.fetchRecentMedia(days: 7, limit: 50)

        // Capture device snapshot
        deviceService.captureSnapshot()
    }

    private func refreshLocationActivities() async {
        logger.debug("Refreshing location activities")
        // Location activities are automatically updated by the service
    }

    private func refreshCalendarActivities() async {
        logger.debug("Refreshing calendar activities")
        await MainActor.run {
            calendarService.fetchThisWeekEvents()
        }
    }

    private func refreshMediaActivities() async {
        logger.debug("Refreshing media activities")
        await MainActor.run {
            mediaService.fetchRecentMedia(days: 7, limit: 50)
        }
    }

    private func refreshDeviceActivities() async {
        logger.debug("Refreshing device activities")
        await MainActor.run {
            deviceService.captureSnapshot()
        }
    }

    private func filterActivitiesByDate() {
        let calendar = Calendar.current

        // This would filter activities, but for now we show all
        // In a real implementation, you'd filter by selectedDate
    }
}

// MARK: - DashboardSummary

struct DashboardSummary {
    let totalLocations: Int
    let totalEvents: Int
    let totalMedia: Int
    let lastUpdate: Date

    var totalActivities: Int {
        totalLocations + totalEvents + totalMedia
    }

    var lastUpdateFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: lastUpdate, relativeTo: Date())
    }
}
