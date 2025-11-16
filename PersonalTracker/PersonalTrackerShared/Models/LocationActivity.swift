import Foundation
import CoreLocation

// MARK: - LocationActivity

/// Represents a tracked location activity with GPS coordinates and related metadata
struct LocationActivity: ActivityRecord {
    let id: UUID
    let timestamp: Date
    let activityType: ActivityType = .location
    var title: String?
    var notes: String?
    var tags: [String]
    var isFavorite: Bool
    var privacyLevel: PrivacyLevel
    var metadata: [String: String]

    // Location-specific properties
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

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        latitude: Double,
        longitude: Double,
        altitude: Double? = nil,
        horizontalAccuracy: Double,
        verticalAccuracy: Double? = nil,
        speed: Double? = nil,
        course: Double? = nil,
        address: String? = nil,
        placeName: String? = nil,
        category: LocationCategory = .other,
        title: String? = nil,
        notes: String? = nil,
        tags: [String] = [],
        isFavorite: Bool = false,
        privacyLevel: PrivacyLevel = .privateLevel,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.speed = speed
        self.course = course
        self.address = address
        self.placeName = placeName
        self.category = category
        self.title = title
        self.notes = notes
        self.tags = tags
        self.isFavorite = isFavorite
        self.privacyLevel = privacyLevel
        self.metadata = metadata
    }

    /// Initialize from CLLocation
    init(
        from location: CLLocation,
        address: String? = nil,
        placeName: String? = nil,
        category: LocationCategory = .other,
        title: String? = nil
    ) {
        self.id = UUID()
        self.timestamp = location.timestamp
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.horizontalAccuracy = location.horizontalAccuracy
        self.verticalAccuracy = location.verticalAccuracy
        self.speed = location.speed >= 0 ? location.speed : nil
        self.course = location.course >= 0 ? location.course : nil
        self.address = address
        self.placeName = placeName
        self.category = category
        self.title = title ?? placeName
        self.notes = nil
        self.tags = []
        self.isFavorite = false
        self.privacyLevel = .privateLevel
        self.metadata = [:]
    }

    /// Convert to CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Returns a human-readable coordinate string
    var coordinateString: String {
        String(format: "%.6f, %.6f", latitude, longitude)
    }

    /// Returns the distance from another location in meters
    func distance(from other: LocationActivity) -> Double {
        let location1 = CLLocation(latitude: latitude, longitude: longitude)
        let location2 = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return location1.distance(from: location2)
    }
}

// MARK: - LocationCategory

/// Categories for different types of locations
enum LocationCategory: String, Codable, CaseIterable {
    case home
    case work
    case restaurant
    case shopping
    case entertainment
    case travel
    case gym
    case healthcare
    case education
    case transportation
    case outdoor
    case other

    var displayName: String {
        switch self {
        case .home: return "Home"
        case .work: return "Work"
        case .restaurant: return "Restaurant"
        case .shopping: return "Shopping"
        case .entertainment: return "Entertainment"
        case .travel: return "Travel"
        case .gym: return "Gym"
        case .healthcare: return "Healthcare"
        case .education: return "Education"
        case .transportation: return "Transportation"
        case .outdoor: return "Outdoor"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .work: return "briefcase.fill"
        case .restaurant: return "fork.knife"
        case .shopping: return "cart.fill"
        case .entertainment: return "ticket.fill"
        case .travel: return "airplane"
        case .gym: return "figure.walk"
        case .healthcare: return "cross.case.fill"
        case .education: return "book.fill"
        case .transportation: return "car.fill"
        case .outdoor: return "leaf.fill"
        case .other: return "mappin.circle.fill"
        }
    }
}

// MARK: - LocationCluster

/// Represents a cluster of nearby locations for visualization
struct LocationCluster: Identifiable {
    let id: UUID
    let centerCoordinate: CLLocationCoordinate2D
    let locations: [LocationActivity]
    let radius: Double

    var count: Int {
        locations.count
    }

    var title: String {
        if let firstPlace = locations.first?.placeName {
            return count > 1 ? "\(firstPlace) +\(count - 1)" : firstPlace
        }
        return "\(count) locations"
    }
}
