import Foundation
import SwiftUI

// MARK: - Date Extensions

extension Date {
    /// Returns a user-friendly relative time string
    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Returns a short relative time string (e.g., "2h ago")
    var shortRelativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Check if date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// Check if date is tomorrow
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    /// Returns start of day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Returns end of day
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
}

// MARK: - String Extensions

extension String {
    /// Check if string is a valid email
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }

    /// Truncate string to a maximum length
    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        }
        return self
    }

    /// Remove whitespace and newlines
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Array Extensions

extension Array where Element: Hashable {
    /// Remove duplicates while preserving order
    var removingDuplicates: [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

extension Array {
    /// Safely access array elements
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    /// Chunk array into groups of specified size
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Double Extensions

extension Double {
    /// Format as percentage
    var asPercentage: String {
        String(format: "%.1f%%", self * 100)
    }

    /// Round to specified decimal places
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// MARK: - Color Extensions

extension Color {
    /// Initialize color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }

    /// App theme colors
    static let primaryAccent = Color(hex: "007AFF")
    static let secondaryAccent = Color(hex: "5856D6")
    static let success = Color(hex: "34C759")
    static let warning = Color(hex: "FF9500")
    static let danger = Color(hex: "FF3B30")
}

// MARK: - View Extensions

extension View {
    /// Apply rounded card style
    func cardStyle(padding: CGFloat = 16, cornerRadius: CGFloat = 12) -> some View {
        self
            .padding(padding)
            #if os(iOS)
            .background(Color(.systemBackground))
            #elseif os(macOS)
            .background(Color(NSColor.controlBackgroundColor))
            #endif
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    /// Conditional modifier
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Add accessibility label and hint
    func accessibilityLabel(_ label: String, hint: String? = nil) -> some View {
        Group {
            if let hint = hint {
                self
                    .accessibilityLabel(label)
                    .accessibilityHint(hint)
            } else {
                self
                    .accessibilityLabel(label)
            }
        }
    }
}

// MARK: - UserDefaults Extensions

extension UserDefaults {
    /// Type-safe UserDefaults access
    subscript<T>(key: String) -> T? {
        get {
            value(forKey: key) as? T
        }
        set {
            set(newValue, forKey: key)
        }
    }
}

// MARK: - Result Extensions

extension Result {
    /// Check if result is success
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }

    /// Check if result is failure
    var isFailure: Bool {
        !isSuccess
    }

    /// Get value if success, nil otherwise
    var value: Success? {
        try? get()
    }

    /// Get error if failure, nil otherwise
    var error: Failure? {
        if case let .failure(error) = self {
            return error
        }
        return nil
    }
}
