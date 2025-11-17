import SwiftUI

// MARK: - MacSettingsView

struct MacSettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @EnvironmentObject var dashboardViewModel: DashboardViewModel
    @State private var showingExportSheet = false

    var body: some View {
        TabView {
            // General Settings
            Form {
                Section("Tracking") {
                    Toggle("Track Location", isOn: binding(for: \.trackLocation))
                    Toggle("Track Calendar", isOn: binding(for: \.trackCalendar))
                    Toggle("Track Media", isOn: binding(for: \.trackMedia))
                    Toggle("Track URLs", isOn: binding(for: \.trackURLs))
                    Toggle("Track Device Info", isOn: binding(for: \.trackDevice))
                }

                Section("Security") {
                    Toggle("Require Authentication", isOn: binding(for: \.requireAuthentication))
                    Toggle("Encrypt Sensitive Data", isOn: binding(for: \.encryptSensitiveData))

                    Picker("Data Retention", selection: $viewModel.privacySettings.dataRetentionDays) {
                        Text("30 Days").tag(30)
                        Text("90 Days").tag(90)
                        Text("1 Year").tag(365)
                        Text("Forever").tag(0)
                    }
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label("General", systemImage: "gear")
            }

            // Data Management
            Form {
                Section("Export") {
                    Button("Export All Data...") {
                        showingExportSheet = true
                    }

                    Text("Export your data in JSON or CSV format")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Storage") {
                    LabeledContent("Total Activities", value: "\(totalActivities)")

                    Button("Clear All Data...") {
                        // Show alert
                    }
                    .foregroundColor(.red)
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label("Data", systemImage: "externaldrive")
            }

            // About
            Form {
                Section("Application") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: "1")
                }

                Section("Links") {
                    if let githubURL = URL(string: "https://github.com/yourusername/personal-tracker") {
                        Link("GitHub Repository", destination: githubURL)
                    }
                    if let licenseURL = URL(string: "https://github.com/yourusername/personal-tracker/blob/main/LICENSE") {
                        Link("License", destination: licenseURL)
                    }
                    if let issueURL = URL(string: "https://github.com/yourusername/personal-tracker/issues") {
                        Link("Report Issue", destination: issueURL)
                    }
                }

                Section {
                    Text("Personal Tracker")
                        .font(.headline)
                    Text("Privacy-first activity tracking")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
        }
        .frame(width: 500, height: 400)
        .sheet(isPresented: $showingExportSheet) {
            MacExportSheet(viewModel: viewModel, dashboardViewModel: dashboardViewModel)
        }
    }

    private var totalActivities: Int {
        dashboardViewModel.locationActivities.count +
        dashboardViewModel.calendarActivities.count +
        dashboardViewModel.mediaActivities.count +
        dashboardViewModel.deviceActivities.count
    }

    private func binding(for keyPath: WritableKeyPath<PrivacySettings, Bool>) -> Binding<Bool> {
        Binding(
            get: { viewModel.privacySettings[keyPath: keyPath] },
            set: { _ in viewModel.toggleSetting(keyPath) }
        )
    }
}

// MARK: - MacExportSheet

struct MacExportSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @State private var selectedFormat: DataExportService.ExportFormat = .json
    @State private var exportedURL: URL?

    var body: some View {
        VStack(spacing: 24) {
            // Header
            Text("Export Data")
                .font(.title)
                .fontWeight(.bold)

            // Format Selection
            Picker("Format", selection: $selectedFormat) {
                Text("JSON").tag(DataExportService.ExportFormat.json)
                Text("CSV").tag(DataExportService.ExportFormat.csv)
            }
            .pickerStyle(.segmented)
            .frame(width: 300)

            // Export Summary
            if !allActivities.isEmpty {
                let summary = viewModel.getExportSummary(
                    for: allActivities,
                    format: selectedFormat
                )

                VStack(spacing: 16) {
                    HStack(spacing: 40) {
                        VStack {
                            Text("\(summary.itemCount)")
                                .font(.system(size: 32, weight: .bold))
                            Text("Items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        VStack {
                            Text(summary.formattedSize)
                                .font(.system(size: 32, weight: .bold))
                            Text("Size")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.controlBackgroundColor))
                .cornerRadius(12)
            }

            Spacer()

            // Buttons
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                if viewModel.isExporting {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Button("Export") {
                        exportData()
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
        }
        .padding(32)
        .frame(width: 500, height: 350)
    }

    private var allActivities: [any ActivityRecord] {
        var activities: [any ActivityRecord] = []
        activities.append(contentsOf: dashboardViewModel.locationActivities)
        activities.append(contentsOf: dashboardViewModel.calendarActivities)
        activities.append(contentsOf: dashboardViewModel.mediaActivities)
        activities.append(contentsOf: dashboardViewModel.deviceActivities)
        return activities
    }

    private func exportData() {
        Task {
            do {
                let url = try await viewModel.exportData(
                    activities: allActivities,
                    format: selectedFormat
                )
                exportedURL = url

                // Show in Finder
                NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: "")

                dismiss()
            } catch {
                // Handle error
            }
        }
    }
}

// MARK: - Preview

struct MacSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MacSettingsView()
            .environmentObject(SettingsViewModel())
            .environmentObject(DashboardViewModel())
    }
}
