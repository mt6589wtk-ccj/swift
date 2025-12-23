import SwiftUI

struct ContentView: View {
    // 1. 追蹤登入狀態：預設為 false (未登入)
    @State private var isLoggedIn = false
    
    // 2. 初始化定位管理員：這會傳遞給地圖頁面使用
    @State private var locationManager = LocationManager()

    var body: some View {
        Group {
            if isLoggedIn {
                // 如果已登入，顯示地圖時間軸
                // 我們把 locationManager 傳進去，讓地圖可以存取 GPS 數據
                TimelineView(locationManager: locationManager)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
            } else {
                // 如果未登入，顯示登入畫面
                // 這裡使用 $isLoggedIn (Binding)，讓 LoginView 裡面可以修改這裡的變數
                LoginView(isLoggedIn: $isLoggedIn)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.default, value: isLoggedIn) // 狀態切換時加入平滑動畫
    }
}

#Preview {
    ContentView()
}
