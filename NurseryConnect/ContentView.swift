import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        HomeDashboardView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            Room.self,
            DiaryEntry.self,
            StaffMember.self,
            ChildPresence.self,
            RatioBreach.self,
        ], inMemory: true)
}
