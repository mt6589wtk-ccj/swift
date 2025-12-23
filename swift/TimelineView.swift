import SwiftUI
import MapKit

struct TimelineView: View {
    @Bindable var locationManager: LocationManager
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    // 控制是否顯示會員中心（之後可以跳轉頁面）
    @State private var showMemberCenter = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // --- 自定義上方 Header 區域 ---
                HStack {
                    // 左邊：Logo (這裡先用系統圖示代替，你可以換成自己的圖片)
                    HStack(spacing: 8) {
                        Image(systemName: "map.fill") // 替換成你的 Logo 圖片：Image("your_logo_name")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                        
                        Text("Taichung Circuit") // 你的專案名稱
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    // 右邊：會員中心按鈕
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
                .background(Color(.systemBackground)) // 背景色隨系統切換
                
                Divider() // 加入一條細微的分隔線

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

                    // 放大縮小按鈕
                    VStack(spacing: 12) {
                        Button { zoom(by: 0.5) } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .background(Color.white.clipShape(Circle()))
                                .shadow(radius: 4)
                        }

                        Button { zoom(by: 2.0) } label: {
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
                        Button(action: { locationManager.stopTracking() }) {
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
            .navigationBarHidden(true) // 隱藏原本內建的導覽列，改用我們自訂的 Header
            .sheet(isPresented: $showMemberCenter) {
                // 這裡定義點擊會員中心後彈出的畫面
                MemberCenterView()
            }
        }
    }

    private func zoom(by factor: Double) {
        let center = locationManager.trackPoints.last ?? CLLocationCoordinate2D(latitude: 24.1373, longitude: 120.6866)
        let newSpan = MKCoordinateSpan(latitudeDelta: 0.05 * factor, longitudeDelta: 0.05 * factor)
        let newRegion = MKCoordinateRegion(center: center, span: newSpan)
        withAnimation(.easeInOut) {
            position = .region(newRegion)
        }
    }
}

// 簡單的會員中心預覽頁面
struct MemberCenterView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("會員中心").font(.largeTitle).bold()
            Image(systemName: "person.circle").resizable().frame(width: 100, height: 100)
            Text("匿名用戶").font(.title2)
            List {
                Text("個人基本資料")
                Text("歷史路徑紀錄")
                Text("設定")
            }
        }
        .padding(.top, 50)
    }
}
