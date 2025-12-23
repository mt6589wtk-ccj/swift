import SwiftUI
import MapKit

struct TimelineView: View {
    @Bindable var locationManager: LocationManager
    // 1. 初始化相機位置
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    // 2. 新增：紀錄目前的縮放跨度，預設為 0.05
    @State private var currentSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    
    @State private var showMemberCenter = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // --- 自定義上方 Header 區域 ---
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "map.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                        
                        Text("GPS records")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    Button {
                        showMemberCenter = true
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 28, height: 28)
                            Text("會員中心")
                                .font(.caption2)
                        }
                    }
                    .foregroundColor(.primary)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                
                Divider()

                // --- 下方地圖與控制區域 ---
                ZStack(alignment: .trailing) {
                    MapReader { proxy in
                        Map(position: $position) {
                            MapPolyline(coordinates: locationManager.trackPoints)
                                .stroke(.blue, lineWidth: 6)
                            UserAnnotation()
                        }
                        .mapStyle(.standard(elevation: .realistic))
                        .mapControls {
                            MapUserLocationButton()
                            MapCompass()
                        }
                    }

                    // 靈活的放大縮小按鈕
                    VStack(spacing: 12) {
                        Button {
                            zoom(by: 0.6) // 縮小 Span = 放大地圖 (變為原來的 0.6 倍)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .background(Color.white.clipShape(Circle()))
                                .shadow(radius: 4)
                        }

                        Button {
                            zoom(by: 1.6) // 增大 Span = 縮小地圖 (變為原來的 1.6 倍)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .background(Color.white.clipShape(Circle()))
                                .shadow(radius: 4)
                        }
                    }
                    .padding(.trailing, 16)
                    .foregroundColor(.blue)
                }
                
                // 底部紀錄按鈕
                HStack(spacing: 30) {
                    if !locationManager.isTracking {
                        Button(action: { locationManager.startTracking() }) {
                            Label("開始紀錄", systemImage: "play.fill")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    } else {
                        Button(action: {
                            locationManager.stopTracking()
                            // 呼叫存檔邏輯
                            // 注意：這裡需要取得 modelContext，可在 ContentView 傳入或在此處宣告
                        }) {
                            Label("停止紀錄", systemImage: "stop.fill")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showMemberCenter) {
                MemberCenterView()
            }
        }
    }

    // --- 改進後的靈活縮放邏輯 ---
    private func zoom(by factor: Double) {
        // 1. 基於當前的 Span 進行運算，而不是固定的 0.05
        currentSpan.latitudeDelta *= factor
        currentSpan.longitudeDelta *= factor
        
        // 2. 限制縮放邊界，避免縮到無限大或無限小
        // 最小跨度 0.001 (極度放大), 最大跨度 10.0 (看整個國家)
        currentSpan.latitudeDelta = min(max(currentSpan.latitudeDelta, 0.001), 10.0)
        currentSpan.longitudeDelta = min(max(currentSpan.longitudeDelta, 0.001), 10.0)

        // 3. 取得地圖中心點 (優先使用使用者最後座標)
        let center = locationManager.trackPoints.last ?? CLLocationCoordinate2D(latitude: 24.1373, longitude: 120.6866)
        
        // 4. 使用更平滑的動畫更新相機
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            position = .region(MKCoordinateRegion(center: center, span: currentSpan))
        }
    }
}
