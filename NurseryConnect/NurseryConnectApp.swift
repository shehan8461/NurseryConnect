import SwiftUI
import SwiftData

@main
struct NurseryConnectApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([DiaryEntry.self, RatioSession.self])
        do {
            container = try ModelContainer(for: schema)
        } catch {
            // Schema changed — wipe the incompatible store and start fresh
            let fm = FileManager.default
            if let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                for ext in ["", "-wal", "-shm"] {
                    let url = appSupport.appendingPathComponent("default.store\(ext)")
                    try? fm.removeItem(at: url)
                }
            }
            container = try! ModelContainer(for: schema)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}

