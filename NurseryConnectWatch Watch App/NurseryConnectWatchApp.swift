import SwiftUI
import WatchConnectivity

@main
struct NurseryConnectWatchApp: App {

    @StateObject private var store = WatchDataStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
