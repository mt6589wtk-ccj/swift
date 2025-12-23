import SwiftUI
import SwiftData

struct MemberCenterView: View {
    // 1. 使用 AppStorage 儲存用戶名稱，這會自動永久儲存在手機中
    @AppStorage("username") var username: String = "匿名用戶"
    // 2. 儲存一個固定的 ID，避免每次打開都變動
    @AppStorage("user_id") var userID: String = UUID().uuidString.prefix(8).uppercased()
    
    @Query(sort: \SavedRoute.startTime, order: .reverse) private var allRoutes: [SavedRoute]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // --- 個人基本資料區塊 ---
                Section("個人基本資料") {
                    HStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            // 這裡改為 TextField，讓用戶可以直接點擊修改
                            HStack {
                                TextField("點擊輸入名稱", text: $username)
                                    .font(.headline)
                                    .submitLabel(.done) // 鍵盤顯示「完成」
                                
                                Image(systemName: "pencil")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            
                            Text("ID: \(userID)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 5)
                }

                // --- 歷史路徑清單區塊 ---
                Section("歷史路徑紀錄") {
                    if allRoutes.isEmpty {
                        ContentUnavailableView(
                            "尚無紀錄",
                            systemImage: "map",
                            description: Text("開始紀錄一段路徑並存檔後，它會出現在這裡。")
                        )
                    } else {
                        ForEach(allRoutes) { route in
                            NavigationLink(destination: RouteDetailView(route: route)) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(route.startTime.formatted(date: .abbreviated, time: .shortened))
                                        .font(.body)
                                        .fontWeight(.medium)
                                    
                                    HStack {
                                        Image(systemName: "mappin.and.ellipse")
                                        Text("\(route.latitudes.count) 個定位點")
                                        Spacer()
                                        if let endTime = route.endTime {
                                            Text(formatDuration(start: route.startTime, end: endTime))
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                }
                            }
                        }
                        .onDelete(perform: deleteRoute)
                    }
                }
            }
            .navigationTitle("會員中心")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }

    private func deleteRoute(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(allRoutes[index])
        }
    }

    private func formatDuration(start: Date, end: Date) -> String {
        let diff = end.timeIntervalSince(start)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: diff) ?? ""
    }
}
