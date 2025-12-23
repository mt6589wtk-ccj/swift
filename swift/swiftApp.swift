import SwiftUI
import SwiftData // 1. 導入庫

@main
struct swiftApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SavedRoute.self) // 2. 指定存儲模型
    }
}
