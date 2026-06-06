import SwiftUI

// MARK: - MacContentView

struct MacContentView: View {
    @EnvironmentObject var dashboardViewModel: DashboardViewModel
    @State private var selectedView: SidebarItem = .dashboard
    @State private var searchText = ""

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(SidebarItem.allCases, selection: $selectedView) { item in
                NavigationLink(value: item) {
                    Label(item.title, systemImage: item.icon)
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 300)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar) {
                        Image(systemName: "sidebar.left")
                    }
                    .help("Toggle Sidebar")
                }
            }
        } detail: {
            // Detail View
            Group {
                switch selectedView {
                case .dashboard:
                    MacDashboardView()
                case .activities:
                    MacActivityListView()
                case .privacy:
                    MacPrivacyView()
                case .settings:
                    MacSettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .searchable(text: $searchText, placement: .sidebar)
    }

    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(
            #selector(NSSplitViewController.toggleSidebar(_:)),
            with: nil
        )
    }
}

// MARK: - SidebarItem

enum SidebarItem: String, CaseIterable, Identifiable {
    case dashboard
    case activities
    case privacy
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .activities: return "Activities"
        case .privacy: return "Privacy"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: return "chart.bar.fill"
        case .activities: return "list.bullet"
        case .privacy: return "hand.raised.fill"
        case .settings: return "gear"
        }
    }
}

// MARK: - Preview

struct MacContentView_Previews: PreviewProvider {
    static var previews: some View {
        MacContentView()
            .environmentObject(DashboardViewModel())
            .environmentObject(SettingsViewModel())
            .frame(width: 1000, height: 700)
    }
}
