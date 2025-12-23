import SwiftUI
import SwiftData

struct MemberCenterView: View {
    // 從資料庫自動抓取所有路徑，最新的排在前面
    @Query(sort: \SavedRoute.startTime, order: .reverse) private var allRoutes: [SavedRoute]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // 會員資訊
                Section("個人基本資料") {
                    HStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("匿名用戶")
                                .font(.headline)
                            Text("ID: \(UUID().uuidString.prefix(8))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 5)
                }

                // 歷史紀錄清單
                Section("歷史路徑紀錄") {
                    if allRoutes.isEmpty {
                        ContentUnavailableView("尚無紀錄", systemImage: "map", description: Text("開始紀錄一段路徑並存檔後，它會出現在這裡。"))
                    } else {
                        ForEach(allRoutes) { route in
                            // 點擊後跳轉到 RouteDetailView
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
                        .onDelete(perform: deleteRoute) // 支援滑動刪除
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
