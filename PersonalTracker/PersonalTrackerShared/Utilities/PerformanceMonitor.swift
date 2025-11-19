import Foundation
import os.signpost

// MARK: - PerformanceMonitor

/// Performance monitoring and profiling utilities
enum PerformanceMonitor {
    private static let log = OSLog(subsystem: "com.personaltracker", category: "performance")
    
    // MARK: - Signposts
    
    /// Begin a performance measurement
    /// - Parameter name: Name of the operation being measured
    static func begin(_ name: StaticString) {
        if #available(iOS 15.0, macOS 12.0, *) {
            os_signpost(.begin, log: log, name: name)
        }
    }
    
    /// End a performance measurement
    /// - Parameter name: Name of the operation being measured
    static func end(_ name: StaticString) {
        if #available(iOS 15.0, macOS 12.0, *) {
            os_signpost(.end, log: log, name: name)
        }
    }
    
    /// Measure the performance of a synchronous operation
    /// - Parameters:
    ///   - name: Name of the operation
    ///   - operation: The operation to measure
    /// - Returns: The result of the operation
    static func measure<T>(_ name: StaticString, operation: () throws -> T) rethrows -> T {
        begin(name)
        defer { end(name) }
        return try operation()
    }
    
    /// Measure the performance of an asynchronous operation
    /// - Parameters:
    ///   - name: Name of the operation
    ///   - operation: The async operation to measure
    /// - Returns: The result of the operation
    static func measure<T>(_ name: StaticString, operation: () async throws -> T) async rethrows -> T {
        begin(name)
        defer { end(name) }
        return try await operation()
    }
    
    // MARK: - Timing
    
    /// Time an operation and log the duration
    /// - Parameters:
    ///   - name: Name of the operation
    ///   - operation: The operation to time
    /// - Returns: The result of the operation
    static func time<T>(_ name: String, operation: () throws -> T) rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        defer {
            let duration = CFAbsoluteTimeGetCurrent() - start
            Logger.performance.info("\(name) took \(String(format: "%.3f", duration))s")
        }
        return try operation()
    }
    
    /// Time an async operation and log the duration
    /// - Parameters:
    ///   - name: Name of the operation
    ///   - operation: The async operation to time
    /// - Returns: The result of the operation
    static func time<T>(_ name: String, operation: () async throws -> T) async rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        defer {
            let duration = CFAbsoluteTimeGetCurrent() - start
            Logger.performance.info("\(name) took \(String(format: "%.3f", duration))s")
        }
        return try await operation()
    }
}

// MARK: - MemoryMonitor

/// Monitor memory usage
enum MemoryMonitor {
    /// Get current memory usage in bytes
    static var currentUsage: UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(
                    mach_task_self_,
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    $0,
                    &count
                )
            }
        }
        
        guard result == KERN_SUCCESS else { return 0 }
        return UInt64(info.resident_size)
    }
    
    /// Get formatted memory usage
    static var formattedUsage: String {
        ByteCountFormatter.string(fromByteCount: Int64(currentUsage), countStyle: .memory)
    }
    
    /// Log current memory usage
    static func logUsage(_ context: String = "") {
        let usage = formattedUsage
        let message = context.isEmpty ? "Memory usage: \(usage)" : "\(context) - Memory usage: \(usage)"
        Logger.performance.info("\(message)")
    }
    
    /// Monitor memory usage during an operation
    /// - Parameters:
    ///   - name: Name of the operation
    ///   - operation: The operation to monitor
    /// - Returns: The result of the operation
    static func monitor<T>(_ name: String, operation: () throws -> T) rethrows -> T {
        let before = currentUsage
        let result = try operation()
        let after = currentUsage
        let delta = Int64(after) - Int64(before)
        let formatted = ByteCountFormatter.string(fromByteCount: delta, countStyle: .memory)
        Logger.performance.info("\(name) memory delta: \(formatted)")
        return result
    }
}

// MARK: - FPSMonitor

#if os(iOS)
import QuartzCore

/// Monitor frames per second (SwiftUI) - iOS only
@available(iOS 15.0, *)
class FPSMonitor: ObservableObject {
    @Published private(set) var fps: Double = 0

    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount: Int = 0

    func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func update(displayLink: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = displayLink.timestamp
            return
        }

        frameCount += 1
        let elapsed = displayLink.timestamp - lastTimestamp

        if elapsed >= 1.0 {
            fps = Double(frameCount) / elapsed
            frameCount = 0
            lastTimestamp = displayLink.timestamp

            if fps < 50 {
                Logger.performance.warning("Low FPS: \(String(format: "%.1f", self.fps))")
            }
        }
    }

    deinit {
        stop()
    }
}
#endif

// MARK: - BatteryMonitor

/// Monitor battery usage
enum BatteryMonitor {
    #if os(iOS)
    /// Check if low power mode is enabled
    static var isLowPowerModeEnabled: Bool {
        ProcessInfo.processInfo.isLowPowerModeEnabled
    }
    
    /// Get current battery level (0.0 to 1.0)
    static var batteryLevel: Float {
        UIDevice.current.isBatteryMonitoringEnabled = true
        defer { UIDevice.current.isBatteryMonitoringEnabled = false }
        return UIDevice.current.batteryLevel
    }
    
    /// Get battery state
    static var batteryState: UIDevice.BatteryState {
        UIDevice.current.isBatteryMonitoringEnabled = true
        defer { UIDevice.current.isBatteryMonitoringEnabled = false }
        return UIDevice.current.batteryState
    }
    
    /// Log battery status
    static func logStatus() {
        let level = Int(batteryLevel * 100)
        let state = batteryState
        let lowPower = isLowPowerModeEnabled
        
        Logger.performance.info(
            "Battery: \(level)%, State: \(String(describing: state)), Low Power: \(lowPower)"
        )
    }
    #endif
}

// MARK: - NetworkMonitor

/// Monitor network conditions
import Network

@available(iOS 14.0, macOS 11.0, *)
class NetworkMonitor: ObservableObject {
    @Published private(set) var isConnected: Bool = false
    @Published private(set) var connectionType: NWInterface.InterfaceType?
    @Published private(set) var isExpensive: Bool = false
    @Published private(set) var isConstrained: Bool = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.personaltracker.network")
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type
                self?.isExpensive = path.isExpensive
                self?.isConstrained = path.isConstrained
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    /// Log network status
    func logStatus() {
        Logger.performance.info(
            """
            Network: Connected=\(isConnected), \
            Type=\(String(describing: connectionType)), \
            Expensive=\(isExpensive), \
            Constrained=\(isConstrained)
            """
        )
    }
}

// MARK: - Logger Extension

extension Logger {
    static let performance = Logger(
        subsystem: "com.personaltracker",
        category: "performance"
    )
}
