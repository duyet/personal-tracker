import SwiftUI

// MARK: - PrivacyView

struct PrivacyView: View {
    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        NavigationView {
            List {
                // Privacy Score Section
                Section {
                    if let recommendation = viewModel.privacyRecommendation {
                        PrivacyScoreCard(recommendation: recommendation)
                    }
                }

                // Permissions Section
                Section("Permissions") {
                    PermissionRow(
                        icon: "location.fill",
                        title: "Location",
                        status: viewModel.permissionStatus.location,
                        action: {
                            viewModel.requestLocationPermission()
                        }
                    )

                    PermissionRow(
                        icon: "calendar",
                        title: "Calendar",
                        status: viewModel.permissionStatus.calendar,
                        action: {
                            Task {
                                await viewModel.requestCalendarPermission()
                            }
                        }
                    )

                    PermissionRow(
                        icon: "photo.fill",
                        title: "Photos",
                        status: viewModel.permissionStatus.photos,
                        action: {
                            Task {
                                await viewModel.requestPhotosPermission()
                            }
                        }
                    )
                }

                // Privacy Settings Section
                Section("Privacy Settings") {
                    Toggle("Require Authentication", isOn: binding(for: \.requireAuthentication))
                    Toggle("Encrypt Sensitive Data", isOn: binding(for: \.encryptSensitiveData))
                    Toggle("Enable Cloud Sync", isOn: binding(for: \.cloudSyncEnabled))
                }

                // Privacy Issues Section
                if let recommendation = viewModel.privacyRecommendation,
                   !recommendation.issues.isEmpty {
                    Section("Privacy Recommendations") {
                        ForEach(recommendation.issues, id: \.title) { issue in
                            PrivacyIssueRow(issue: issue)
                        }
                    }
                }
            }
            .navigationTitle("Privacy")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Check") {
                        viewModel.checkPermissions()
                    }
                }
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

// MARK: - PrivacyScoreCard

struct PrivacyScoreCard: View {
    let recommendation: PrivacyRecommendation

    var body: some View {
        VStack(spacing: 16) {
            // Score Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: recommendation.score / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text(recommendation.scoreFormatted)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(scoreColor)

                    Text("Privacy Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 150, height: 150)

            // Level Badge
            HStack {
                Image(systemName: recommendation.level.icon)
                Text(recommendation.level.displayName)
            }
            .font(.headline)
            .foregroundColor(scoreColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(scoreColor.opacity(0.1))
            .cornerRadius(20)

            // Summary
            Text(recommendation.summary)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }

    private var scoreColor: Color {
        switch recommendation.level {
        case .high: return .green
        case .medium: return .yellow
        case .low: return .red
        }
    }
}

// MARK: - PermissionRow

struct PermissionRow: View {
    let icon: String
    let title: String
    let status: PermissionState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.primaryAccent)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)

                    Text(status.displayName)
                        .font(.caption)
                        .foregroundColor(statusColor)
                }

                Spacer()

                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
            }
        }
    }

    private var statusColor: Color {
        switch status {
        case .authorized, .limited: return .green
        case .denied, .restricted: return .red
        case .notDetermined: return .orange
        }
    }

    private var statusIcon: String {
        switch status {
        case .authorized, .limited: return "checkmark.circle.fill"
        case .denied, .restricted: return "xmark.circle.fill"
        case .notDetermined: return "questionmark.circle.fill"
        }
    }
}

// MARK: - PrivacyIssueRow

struct PrivacyIssueRow: View {
    let issue: PrivacyIssue

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(severityColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(issue.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(issue.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var severityColor: Color {
        switch issue.severity {
        case "high": return .red
        case "medium": return .orange
        case "low": return .yellow
        default: return .gray
        }
    }
}

// MARK: - Preview

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
            .environmentObject(SettingsViewModel())
    }
}
