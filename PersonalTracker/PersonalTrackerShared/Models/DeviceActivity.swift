import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - DeviceActivity

/// Represents device information and usage metadata
struct DeviceActivity: ActivityRecord {
    let id: UUID
    let timestamp: Date
    let activityType: ActivityType = .device
    var title: String?
    var notes: String?
    var tags: [String]
    var isFavorite: Bool
    var privacyLevel: PrivacyLevel
    var metadata: [String: String]

    // Device-specific properties
    let deviceName: String
    let deviceModel: String
    let deviceIdentifier: String?
    let systemName: String
    let systemVersion: String
    let batteryLevel: Float?
    let batteryState: BatteryState?
    let storageUsed: Int64?
    let storageTotal: Int64?
    let memoryUsed: Int64?
    let memoryTotal: Int64?
    let isLowPowerMode: Bool
    let screenBrightness: Float?
    let deviceOrientation: DeviceOrientation?
    let networkType: NetworkType?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        deviceName: String,
        deviceModel: String,
        deviceIdentifier: String? = nil,
        systemName: String,
        systemVersion: String,
        batteryLevel: Float? = nil,
        batteryState: BatteryState? = nil,
        storageUsed: Int64? = nil,
        storageTotal: Int64? = nil,
        memoryUsed: Int64? = nil,
        memoryTotal: Int64? = nil,
        isLowPowerMode: Bool = false,
        screenBrightness: Float? = nil,
        deviceOrientation: DeviceOrientation? = nil,
        networkType: NetworkType? = nil,
        title: String? = nil,
        notes: String? = nil,
        tags: [String] = [],
        isFavorite: Bool = false,
        privacyLevel: PrivacyLevel = .privateLevel,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.deviceName = deviceName
        self.deviceModel = deviceModel
        self.deviceIdentifier = deviceIdentifier
        self.systemName = systemName
        self.systemVersion = systemVersion
        self.batteryLevel = batteryLevel
        self.batteryState = batteryState
        self.storageUsed = storageUsed
        self.storageTotal = storageTotal
        self.memoryUsed = memoryUsed
        self.memoryTotal = memoryTotal
        self.isLowPowerMode = isLowPowerMode
        self.screenBrightness = screenBrightness
        self.deviceOrientation = deviceOrientation
        self.networkType = networkType
        self.title = title ?? "\(deviceName) Status"
        self.notes = notes
        self.tags = tags
        self.isFavorite = isFavorite
        self.privacyLevel = privacyLevel
        self.metadata = metadata
    }

    /// Formatted battery level percentage
    var formattedBatteryLevel: String? {
        guard let batteryLevel = batteryLevel else { return nil }
        return String(format: "%.0f%%", batteryLevel * 100)
    }

    /// Formatted storage usage
    var formattedStorageUsed: String? {
        guard let storageUsed = storageUsed else { return nil }
        return ByteCountFormatter.string(fromByteCount: storageUsed, countStyle: .file)
    }

    /// Formatted total storage
    var formattedStorageTotal: String? {
        guard let storageTotal = storageTotal else { return nil }
        return ByteCountFormatter.string(fromByteCount: storageTotal, countStyle: .file)
    }

    /// Storage usage percentage
    var storageUsagePercentage: Double? {
        guard let used = storageUsed, let total = storageTotal, total > 0 else { return nil }
        return Double(used) / Double(total)
    }

    /// Available storage
    var storageAvailable: Int64? {
        guard let used = storageUsed, let total = storageTotal else { return nil }
        return total - used
    }

    /// Formatted available storage
    var formattedStorageAvailable: String? {
        guard let available = storageAvailable else { return nil }
        return ByteCountFormatter.string(fromByteCount: available, countStyle: .file)
    }

    /// Memory usage percentage
    var memoryUsagePercentage: Double? {
        guard let used = memoryUsed, let total = memoryTotal, total > 0 else { return nil }
        return Double(used) / Double(total)
    }

    /// Check if battery is low (< 20%)
    var isBatteryLow: Bool {
        guard let batteryLevel = batteryLevel else { return false }
        return batteryLevel < 0.2
    }

    /// Check if storage is low (< 10% available)
    var isStorageLow: Bool {
        guard let percentage = storageUsagePercentage else { return false }
        return percentage > 0.9
    }
}

// MARK: - BatteryState

/// Battery charging state
enum BatteryState: String, Codable {
    case unknown
    case unplugged
    case charging
    case full

    var displayName: String {
        switch self {
        case .unknown: return "Unknown"
        case .unplugged: return "Unplugged"
        case .charging: return "Charging"
        case .full: return "Full"
        }
    }

    var icon: String {
        switch self {
        case .unknown: return "battery.0"
        case .unplugged: return "battery.25"
        case .charging: return "battery.100.bolt"
        case .full: return "battery.100"
        }
    }
}

// MARK: - DeviceOrientation

/// Device physical orientation
enum DeviceOrientation: String, Codable {
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight
    case faceUp
    case faceDown
    case unknown

    var displayName: String {
        switch self {
        case .portrait: return "Portrait"
        case .portraitUpsideDown: return "Portrait Upside Down"
        case .landscapeLeft: return "Landscape Left"
        case .landscapeRight: return "Landscape Right"
        case .faceUp: return "Face Up"
        case .faceDown: return "Face Down"
        case .unknown: return "Unknown"
        }
    }
}

// MARK: - NetworkType

/// Type of network connection
enum NetworkType: String, Codable {
    case wifi
    case cellular
    case ethernet
    case offline

    var displayName: String {
        switch self {
        case .wifi: return "Wi-Fi"
        case .cellular: return "Cellular"
        case .ethernet: return "Ethernet"
        case .offline: return "Offline"
        }
    }

    var icon: String {
        switch self {
        case .wifi: return "wifi"
        case .cellular: return "antenna.radiowaves.left.and.right"
        case .ethernet: return "cable.connector"
        case .offline: return "wifi.slash"
        }
    }
}

// MARK: - DeviceActivity Extension

extension DeviceActivity {
    /// Create a snapshot of current device state
    static func currentSnapshot() -> DeviceActivity {
        #if os(iOS)
        let device = UIDevice.current
        let batteryLevel = device.batteryLevel >= 0 ? device.batteryLevel : nil

        let batteryState: BatteryState = {
            switch device.batteryState {
            case .charging: return .charging
            case .full: return .full
            case .unplugged: return .unplugged
            default: return .unknown
            }
        }()

        let orientation: DeviceOrientation = {
            switch device.orientation {
            case .portrait: return .portrait
            case .portraitUpsideDown: return .portraitUpsideDown
            case .landscapeLeft: return .landscapeLeft
            case .landscapeRight: return .landscapeRight
            case .faceUp: return .faceUp
            case .faceDown: return .faceDown
            default: return .unknown
            }
        }()

        return DeviceActivity(
            deviceName: device.name,
            deviceModel: device.model,
            deviceIdentifier: device.identifierForVendor?.uuidString,
            systemName: device.systemName,
            systemVersion: device.systemVersion,
            batteryLevel: batteryLevel,
            batteryState: batteryState,
            isLowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled,
            screenBrightness: Float(UIScreen.main.brightness),
            deviceOrientation: orientation
        )
        #elseif os(macOS)
        let processInfo = ProcessInfo.processInfo

        return DeviceActivity(
            deviceName: Host.current().localizedName ?? "Mac",
            deviceModel: "Mac",
            systemName: "macOS",
            systemVersion: processInfo.operatingSystemVersionString
        )
        #endif
    }
}
