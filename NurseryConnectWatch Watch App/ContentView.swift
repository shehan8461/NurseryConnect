import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var store: WatchDataStore

    var body: some View {
        TabView {
            RatioStatusView()
                .tabItem { Label("Ratio", systemImage: "person.2.fill") }

            PendingAlertsView()
                .tabItem { Label("Diary", systemImage: "book.fill") }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WatchDataStore())
}
