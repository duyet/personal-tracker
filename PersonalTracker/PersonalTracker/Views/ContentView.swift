import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @EnvironmentObject var dashboardViewModel: DashboardViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(0)

            ActivityListView()
                .tabItem {
                    Label("Activities", systemImage: "list.bullet")
                }
                .tag(1)

            PrivacyView()
                .tabItem {
                    Label("Privacy", systemImage: "hand.raised.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DashboardViewModel())
            .environmentObject(SettingsViewModel())
    }
}
