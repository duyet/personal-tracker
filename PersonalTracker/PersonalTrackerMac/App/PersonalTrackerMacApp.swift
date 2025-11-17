import SwiftUI

// MARK: - PersonalTrackerMacApp

@main
struct PersonalTrackerMacApp: App {
    @StateObject private var dashboardViewModel = DashboardViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            MacContentView()
                .environmentObject(dashboardViewModel)
                .environmentObject(settingsViewModel)
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {}

            CommandMenu("View") {
                Button("Show Dashboard") {
                    // Navigate to dashboard
                }
                .keyboardShortcut("1", modifiers: .command)

                Button("Show Activities") {
                    // Navigate to activities
                }
                .keyboardShortcut("2", modifiers: .command)

                Button("Show Privacy") {
                    // Navigate to privacy
                }
                .keyboardShortcut("3", modifiers: .command)
            }

            CommandMenu("Data") {
                Button("Export Data...") {
                    // Show export sheet
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])

                Button("Refresh") {
                    // Refresh data
                }
                .keyboardShortcut("r", modifiers: .command)
            }
        }

        Settings {
            MacSettingsView()
                .environmentObject(settingsViewModel)
        }
    }
}
