import Foundation
import CoreLocation
import Combine

// MARK: - LocationTrackingService

/// Service responsible for tracking user location with privacy controls
@available(iOS 14.0, macOS 11.0, *)
final class LocationTrackingService: NSObject, ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var isTracking = false
    @Published private(set) var activities: [LocationActivity] = []
    @Published private(set) var error: LocationError?

    // MARK: - Private Properties

    private let locationManager: CLLocationManager
    private let geocoder = CLGeocoder()
    private var cancellables = Set<AnyCancellable>()

    // Configuration
    private var trackingMode: TrackingMode = .significant
    private var minimumDistance: CLLocationDistance = 100 // meters
    private var minimumTimeInterval: TimeInterval = 300 // 5 minutes

    // MARK: - Initialization

    override init() {
        locationManager = CLLocationManager()
        super.init()
        setupLocationManager()
    }

    // MARK: - Public Methods

    /// Request location permission from the user
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// Request always authorization for background tracking
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    /// Start tracking location
    func startTracking(mode: TrackingMode = .significant) {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            error = .permissionDenied
            return
        }

        trackingMode = mode
        isTracking = true

        switch mode {
        case .continuous:
            locationManager.startUpdatingLocation()
        case .significant:
            locationManager.startMonitoringSignificantLocationChanges()
        case .visit:
            locationManager.startMonitoringVisits()
        }
    }

    /// Stop tracking location
    func stopTracking() {
        isTracking = false
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopMonitoringVisits()
    }

    /// Request a single location update
    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            error = .permissionDenied
            return
        }
        locationManager.requestLocation()
    }

    /// Configure tracking parameters
    func configure(
        minimumDistance: CLLocationDistance? = nil,
        minimumTimeInterval: TimeInterval? = nil,
        desiredAccuracy: CLLocationAccuracy? = nil
    ) {
        if let distance = minimumDistance {
            self.minimumDistance = distance
            locationManager.distanceFilter = distance
        }

        if let interval = minimumTimeInterval {
            self.minimumTimeInterval = interval
        }

        if let accuracy = desiredAccuracy {
            locationManager.desiredAccuracy = accuracy
        }
    }

    /// Clear all tracked activities
    func clearActivities() {
        activities.removeAll()
    }

    // MARK: - Private Methods

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = minimumDistance
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = true
        authorizationStatus = locationManager.authorizationStatus
    }

    private func processLocation(_ location: CLLocation) {
        currentLocation = location

        // Reverse geocode to get address
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, error == nil else { return }

            let placemark = placemarks?.first
            let address = self.formatAddress(from: placemark)
            let placeName = placemark?.name

            let activity = LocationActivity(
                from: location,
                address: address,
                placeName: placeName,
                category: self.categorizeLocation(placemark: placemark)
            )

            // Add only if enough time has passed since last location
            if self.shouldAddActivity(activity) {
                DispatchQueue.main.async {
                    self.activities.append(activity)
                }
            }
        }
    }

    private func shouldAddActivity(_ activity: LocationActivity) -> Bool {
        guard let lastActivity = activities.last else { return true }

        // Check time interval
        let timeDifference = activity.timestamp.timeIntervalSince(lastActivity.timestamp)
        guard timeDifference >= minimumTimeInterval else { return false }

        // Check distance
        let distance = activity.distance(from: lastActivity)
        return distance >= minimumDistance
    }

    private func formatAddress(from placemark: CLPlacemark?) -> String? {
        guard let placemark = placemark else { return nil }

        var components: [String] = []

        if let street = placemark.thoroughfare {
            components.append(street)
        }
        if let city = placemark.locality {
            components.append(city)
        }
        if let state = placemark.administrativeArea {
            components.append(state)
        }
        if let country = placemark.country {
            components.append(country)
        }

        return components.isEmpty ? nil : components.joined(separator: ", ")
    }

    private func categorizeLocation(placemark: CLPlacemark?) -> LocationCategory {
        guard let placemark = placemark else { return .other }

        // Simple categorization based on place type
        if let areasOfInterest = placemark.areasOfInterest {
            let combined = areasOfInterest.joined(separator: " ").lowercased()

            if combined.contains("restaurant") || combined.contains("cafe") {
                return .restaurant
            } else if combined.contains("shop") || combined.contains("store") || combined.contains("mall") {
                return .shopping
            } else if combined.contains("gym") || combined.contains("fitness") {
                return .gym
            } else if combined.contains("hospital") || combined.contains("clinic") {
                return .healthcare
            } else if combined.contains("school") || combined.contains("university") {
                return .education
            } else if combined.contains("park") || combined.contains("trail") {
                return .outdoor
            }
        }

        return .other
    }
}

// MARK: - CLLocationManagerDelegate

@available(iOS 14.0, macOS 11.0, *)
extension LocationTrackingService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        if authorizationStatus == .denied || authorizationStatus == .restricted {
            error = .permissionDenied
            stopTracking()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        processLocation(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                self.error = .permissionDenied
            case .network:
                self.error = .networkUnavailable
            default:
                self.error = .unknown(error.localizedDescription)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        let location = CLLocation(
            latitude: visit.coordinate.latitude,
            longitude: visit.coordinate.longitude
        )
        processLocation(location)
    }
}

// MARK: - TrackingMode

/// Mode for location tracking
enum TrackingMode {
    case continuous // Frequent updates
    case significant // Only significant location changes
    case visit // Monitor visits to locations
}

// MARK: - LocationError

/// Errors that can occur during location tracking
enum LocationError: LocalizedError {
    case permissionDenied
    case networkUnavailable
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission denied. Please enable in Settings."
        case .networkUnavailable:
            return "Network unavailable for location services."
        case .unknown(let message):
            return "Location error: \(message)"
        }
    }
}
