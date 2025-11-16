import Foundation
import EventKit
import Combine

// MARK: - CalendarService

/// Service for accessing and tracking calendar events
@available(iOS 14.0, macOS 11.0, *)
final class CalendarService: ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published private(set) var activities: [CalendarActivity] = []
    @Published private(set) var error: CalendarError?
    @Published private(set) var isLoading = false

    // MARK: - Private Properties

    private let eventStore = EKEventStore()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        checkAuthorizationStatus()
    }

    // MARK: - Public Methods

    /// Request calendar access permission
    func requestPermission() async throws {
        if #available(iOS 17.0, macOS 14.0, *) {
            let granted = try await eventStore.requestFullAccessToEvents()
            DispatchQueue.main.async {
                self.authorizationStatus = granted ? .fullAccess : .denied
            }
        } else {
            let granted = try await eventStore.requestAccess(to: .event)
            DispatchQueue.main.async {
                self.authorizationStatus = granted ? .authorized : .denied
            }
        }
    }

    /// Fetch calendar events for a date range
    func fetchEvents(from startDate: Date, to endDate: Date) {
        guard isAuthorized else {
            error = .permissionDenied
            return
        }

        isLoading = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let predicate = self.eventStore.predicateForEvents(
                withStart: startDate,
                end: endDate,
                calendars: nil
            )

            let events = self.eventStore.events(matching: predicate)
            let calendarActivities = events.map { CalendarActivity(from: $0) }

            DispatchQueue.main.async {
                self.activities = calendarActivities
                self.isLoading = false
            }
        }
    }

    /// Fetch events for today
    func fetchTodayEvents() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }

        fetchEvents(from: startOfDay, to: endOfDay)
    }

    /// Fetch events for this week
    func fetchThisWeekEvents() {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start,
              let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.end else { return }

        fetchEvents(from: startOfWeek, to: endOfWeek)
    }

    /// Fetch events for this month
    func fetchThisMonthEvents() {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start,
              let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end else { return }

        fetchEvents(from: startOfMonth, to: endOfMonth)
    }

    /// Fetch upcoming events
    func fetchUpcomingEvents(days: Int = 7) {
        let now = Date()
        guard let endDate = Calendar.current.date(byAdding: .day, value: days, to: now) else { return }

        fetchEvents(from: now, to: endDate)
    }

    /// Get all available calendars
    func getCalendars() -> [EKCalendar] {
        guard isAuthorized else { return [] }
        return eventStore.calendars(for: .event)
    }

    /// Get calendar statistics
    func getStatistics(for activities: [CalendarActivity]) -> CalendarStatistics {
        CalendarStatistics.calculate(from: activities)
    }

    /// Clear all cached activities
    func clearActivities() {
        activities.removeAll()
    }

    // MARK: - Private Methods

    private func checkAuthorizationStatus() {
        if #available(iOS 17.0, macOS 14.0, *) {
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        } else {
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        }
    }

    private var isAuthorized: Bool {
        if #available(iOS 17.0, macOS 14.0, *) {
            return authorizationStatus == .fullAccess || authorizationStatus == .writeOnly
        } else {
            return authorizationStatus == .authorized
        }
    }
}

// MARK: - CalendarError

/// Errors that can occur with calendar access
enum CalendarError: LocalizedError {
    case permissionDenied
    case fetchFailed
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Calendar permission denied. Please enable in Settings."
        case .fetchFailed:
            return "Failed to fetch calendar events."
        case .unknown(let message):
            return "Calendar error: \(message)"
        }
    }
}

// MARK: - CalendarStatistics

/// Statistics for calendar activities
struct CalendarStatistics {
    let totalEvents: Int
    let upcomingEvents: Int
    let pastEvents: Int
    let todayEvents: Int
    let totalDuration: TimeInterval
    let averageDuration: TimeInterval
    let longestEvent: CalendarActivity?
    let mostCommonLocation: String?
    let eventsByType: [CalendarEventType: Int]
    let eventsByDay: [String: Int]

    var formattedTotalDuration: String {
        let hours = Int(totalDuration) / 3600
        return "\(hours)h"
    }

    static func calculate(from activities: [CalendarActivity]) -> CalendarStatistics {
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        let totalEvents = activities.count
        let upcomingEvents = activities.filter { $0.isFuture }.count
        let pastEvents = activities.filter { $0.isPast }.count
        let todayEvents = activities.filter {
            calendar.isDate($0.startDate, inSameDayAs: today)
        }.count

        let totalDuration = activities.reduce(0) { $0 + $1.duration }
        let averageDuration = totalEvents > 0 ? totalDuration / Double(totalEvents) : 0
        let longestEvent = activities.max { $0.duration < $1.duration }

        // Find most common location
        let locations = activities.compactMap { $0.location }
        let locationCounts = Dictionary(grouping: locations, by: { $0 }).mapValues { $0.count }
        let mostCommonLocation = locationCounts.max { $0.value < $1.value }?.key

        // Events by type
        let eventsByType = Dictionary(grouping: activities, by: { $0.eventType })
            .mapValues { $0.count }

        // Events by day of week
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let eventsByDay = Dictionary(
            grouping: activities,
            by: { dateFormatter.string(from: $0.startDate) }
        ).mapValues { $0.count }

        return CalendarStatistics(
            totalEvents: totalEvents,
            upcomingEvents: upcomingEvents,
            pastEvents: pastEvents,
            todayEvents: todayEvents,
            totalDuration: totalDuration,
            averageDuration: averageDuration,
            longestEvent: longestEvent,
            mostCommonLocation: mostCommonLocation,
            eventsByType: eventsByType,
            eventsByDay: eventsByDay
        )
    }
}
