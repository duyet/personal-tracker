import SwiftUI

// MARK: - PersonalTrackerApp

@main
struct PersonalTrackerApp: App {
    @StateObject private var dashboardViewModel = DashboardViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dashboardViewModel)
                .environmentObject(settingsViewModel)
        }
    }
}
