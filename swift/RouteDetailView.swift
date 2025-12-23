import SwiftUI
import MapKit

struct RouteDetailView: View {
    let route: SavedRoute
    @State private var position: MapCameraPosition

    init(route: SavedRoute) {
        self.route = route
        // 初始化相機位置，如果有起點就對準起點，否則自動
        if let first = route.coordinates.first {
            _position = State(initialValue: .region(MKCoordinateRegion(
                center: first,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )))
        } else {
            _position = State(initialValue: .automatic)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 詳情地圖展示
            Map(position: $position) {
                // 畫出歷史軌跡
                MapPolyline(coordinates: route.coordinates)
                    .stroke(.blue, lineWidth: 5)
                
                // 標記起點與終點
                if let first = route.coordinates.first {
                    Annotation("起點", coordinate: first) {
                        Image(systemName: "play.circle.fill").foregroundColor(.green)
                    }
                }
                
                if let last = route.coordinates.last {
                    Annotation("終點", coordinate: last) {
                        Image(systemName: "stop.circle.fill").foregroundColor(.red)
                    }
                }
            }
            .mapStyle(.standard)
            
            // 下方詳細資料列表
            List {
                Section("行程資訊") {
                    LabeledContent("開始時間", value: route.startTime.formatted(date: .numeric, time: .shortened))
                    if let end = route.endTime {
                        LabeledContent("結束時間", value: end.formatted(date: .numeric, time: .shortened))
                    }
                    LabeledContent("點位總數", value: "\(route.latitudes.count)")
                }
            }
            .frame(height: 250)
        }
        .navigationTitle("路徑回顧")
        .navigationBarTitleDisplayMode(.inline)
    }
}
