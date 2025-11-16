import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @EnvironmentObject var dashboardViewModel: DashboardViewModel
    @State private var showingExportSheet = false
    @State private var showingClearAlert = false

    var body: some View {
        NavigationView {
            List {
                // Tracking Section
                Section("Tracking") {
                    Toggle("Track Location", isOn: binding(for: \.trackLocation))
                    Toggle("Track Calendar", isOn: binding(for: \.trackCalendar))
                    Toggle("Track Media", isOn: binding(for: \.trackMedia))
                    Toggle("Track URLs", isOn: binding(for: \.trackURLs))
                    Toggle("Track Device Info", isOn: binding(for: \.trackDevice))
                }

                // Data Management Section
                Section("Data Management") {
                    Button(action: { showingExportSheet = true }) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive, action: { showingClearAlert = true }) {
                        Label("Clear All Data", systemImage: "trash")
                    }
                }

                // Security Section
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

                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }

                    Link(destination: URL(string: "https://github.com/yourusername/personal-tracker")!) {
                        HStack {
                            Text("GitHub")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Link(destination: URL(string: "https://github.com/yourusername/personal-tracker/blob/main/LICENSE")!) {
                        HStack {
                            Text("License")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingExportSheet) {
                ExportSheet(viewModel: viewModel, dashboardViewModel: dashboardViewModel)
            }
            .alert("Clear All Data", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    viewModel.clearAllData()
                }
            } message: {
                Text("Are you sure you want to clear all tracked data? This action cannot be undone.")
            }
        }
    }

    private func binding(for keyPath: WritableKeyPath<PrivacySettings, Bool>) -> Binding<Bool> {
        Binding(
            get: { viewModel.privacySettings[keyPath: keyPath] },
            set: { _ in viewModel.toggleSetting(keyPath) }
        )
    }
}

// MARK: - ExportSheet

struct ExportSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @State private var selectedFormat: DataExportService.ExportFormat = .json
    @State private var exportedURL: URL?
    @State private var showingShareSheet = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Format Selection
                Picker("Export Format", selection: $selectedFormat) {
                    Text("JSON").tag(DataExportService.ExportFormat.json)
                    Text("CSV").tag(DataExportService.ExportFormat.csv)
                }
                .pickerStyle(.segmented)
                .padding()

                // Export Summary
                if !allActivities.isEmpty {
                    VStack(spacing: 12) {
                        Text("Export Summary")
                            .font(.headline)

                        let summary = viewModel.getExportSummary(
                            for: allActivities,
                            format: selectedFormat
                        )

                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(summary.itemCount) items")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text(summary.formatName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing) {
                                Text(summary.formattedSize)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Estimated Size")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding()
                }

                // Export Button
                if viewModel.isExporting {
                    ProgressView(value: viewModel.exportProgress) {
                        Text("Exporting...")
                    }
                    .padding()
                } else {
                    Button(action: exportData) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryAccent)
                            .cornerRadius(12)
                    }
                    .padding()
                }

                Spacer()
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportedURL {
                    ShareSheet(items: [url])
                }
            }
            .alert("Export Successful", isPresented: $viewModel.showingExportSuccess) {
                Button("Share") {
                    showingShareSheet = true
                }
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Your data has been exported successfully.")
            }
        }
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
            } catch {
                // Handle error
            }
        }
    }
}

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsViewModel())
            .environmentObject(DashboardViewModel())
    }
}
