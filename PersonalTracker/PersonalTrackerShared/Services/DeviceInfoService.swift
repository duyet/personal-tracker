import Foundation
import Combine

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - DeviceInfoService

/// Service for collecting device information and system metrics
@available(iOS 14.0, macOS 11.0, *)
final class DeviceInfoService: ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var currentSnapshot: DeviceActivity?
    @Published private(set) var activities: [DeviceActivity] = []
    @Published private(set) var isMonitoring = false

    // MARK: - Private Properties

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var monitoringInterval: TimeInterval = 300 // 5 minutes

    // MARK: - Initialization

    init() {
        setupNotifications()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Public Methods

    /// Capture current device snapshot
    func captureSnapshot() {
        let snapshot = DeviceActivity.currentSnapshot()
        currentSnapshot = snapshot
        activities.append(snapshot)
    }

    /// Start monitoring device information
    func startMonitoring(interval: TimeInterval = 300) {
        guard !isMonitoring else { return }

        monitoringInterval = interval
        isMonitoring = true

        // Capture initial snapshot
        captureSnapshot()

        // Setup timer for periodic snapshots
        timer = Timer.scheduledTimer(
            withTimeInterval: monitoringInterval,
            repeats: true
        ) { [weak self] _ in
            self?.captureSnapshot()
        }
    }

    /// Stop monitoring device information
    func stopMonitoring() {
        isMonitoring = false
        timer?.invalidate()
        timer = nil
    }

    /// Get device statistics
    func getStatistics() -> DeviceStatistics {
        DeviceStatistics.calculate(from: activities)
    }

    /// Clear all cached activities
    func clearActivities() {
        activities.removeAll()
        currentSnapshot = nil
    }

    /// Get system information
    func getSystemInfo() -> SystemInfo {
        SystemInfo.current()
    }

    // MARK: - Private Methods

    private func setupNotifications() {
        #if os(iOS)
        // Battery state notifications
        UIDevice.current.isBatteryMonitoringEnabled = true

        NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification)
            .sink { [weak self] _ in
                self?.captureSnapshot()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIDevice.batteryLevelDidChangeNotification)
            .sink { [weak self] _ in
                self?.captureSnapshot()
            }
            .store(in: &cancellables)

        // Low power mode notification
        NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange)
            .sink { [weak self] _ in
                self?.captureSnapshot()
            }
            .store(in: &cancellables)
        #endif
    }
}

// MARK: - SystemInfo

/// Detailed system information
struct SystemInfo: Codable {
    let deviceName: String
    let deviceModel: String
    let systemName: String
    let systemVersion: String
    let processorCount: Int
    let physicalMemory: UInt64
    let systemUptime: TimeInterval

    var formattedPhysicalMemory: String {
        ByteCountFormatter.string(fromByteCount: Int64(physicalMemory), countStyle: .memory)
    }

    var formattedUptime: String {
        let hours = Int(systemUptime) / 3600
        let minutes = (Int(systemUptime) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    static func current() -> SystemInfo {
        let processInfo = ProcessInfo.processInfo

        #if os(iOS)
        let device = UIDevice.current
        return SystemInfo(
            deviceName: device.name,
            deviceModel: device.model,
            systemName: device.systemName,
            systemVersion: device.systemVersion,
            processorCount: processInfo.processorCount,
            physicalMemory: processInfo.physicalMemory,
            systemUptime: processInfo.systemUptime
        )
        #elseif os(macOS)
        return SystemInfo(
            deviceName: Host.current().localizedName ?? "Mac",
            deviceModel: "Mac",
            systemName: "macOS",
            systemVersion: processInfo.operatingSystemVersionString,
            processorCount: processInfo.processorCount,
            physicalMemory: processInfo.physicalMemory,
            systemUptime: processInfo.systemUptime
        )
        #endif
    }
}

// MARK: - DeviceStatistics

/// Statistics for device activities
struct DeviceStatistics {
    let totalSnapshots: Int
    let averageBatteryLevel: Float?
    let lowestBatteryLevel: Float?
    let highestBatteryLevel: Float?
    let averageStorageUsage: Double?
    let lowPowerModeCount: Int
    let chargingCount: Int

    var formattedAverageBattery: String? {
        guard let level = averageBatteryLevel else { return nil }
        return String(format: "%.0f%%", level * 100)
    }

    static func calculate(from activities: [DeviceActivity]) -> DeviceStatistics {
        let totalSnapshots = activities.count

        let batteryLevels = activities.compactMap { $0.batteryLevel }
        let averageBatteryLevel = batteryLevels.isEmpty ? nil :
            batteryLevels.reduce(0, +) / Float(batteryLevels.count)
        let lowestBatteryLevel = batteryLevels.min()
        let highestBatteryLevel = batteryLevels.max()

        let storageUsages = activities.compactMap { $0.storageUsagePercentage }
        let averageStorageUsage = storageUsages.isEmpty ? nil :
            storageUsages.reduce(0, +) / Double(storageUsages.count)

        let lowPowerModeCount = activities.filter { $0.isLowPowerMode }.count
        let chargingCount = activities.filter { $0.batteryState == .charging }.count

        return DeviceStatistics(
            totalSnapshots: totalSnapshots,
            averageBatteryLevel: averageBatteryLevel,
            lowestBatteryLevel: lowestBatteryLevel,
            highestBatteryLevel: highestBatteryLevel,
            averageStorageUsage: averageStorageUsage,
            lowPowerModeCount: lowPowerModeCount,
            chargingCount: chargingCount
        )
    }
}
