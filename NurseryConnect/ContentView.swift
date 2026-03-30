
import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        HomeDashboardView()
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [
                DiaryEntry.self,
                RatioSession.self,
            ],
            inMemory: true
        )
}
