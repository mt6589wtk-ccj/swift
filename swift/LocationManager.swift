import CoreLocation
import Observation
import SwiftData

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    // 儲存所有經過的座標點（用於畫線）
    var trackPoints: [CLLocationCoordinate2D] = []
    
    // 記錄目前是否正在追蹤中
    var isTracking: Bool = false
    
    @MainActor
        func saveCurrentRoute(context: ModelContext) {
            guard !trackPoints.isEmpty else { return }
            
            let lats = trackPoints.map { $0.latitude }
            let lons = trackPoints.map { $0.longitude }
            
            let newRoute = SavedRoute(startTime: Date(), latitudes: lats, longitudes: lons)
            newRoute.endTime = Date()
            
            context.insert(newRoute) // 插入資料庫
            
            do {
                try context.save()
                print("路徑存檔成功！")
                trackPoints.removeAll() // 存完後清空當前畫面線條
            } catch {
                print("存檔失敗: \(error)")
            }
        }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest // 最高精度
        manager.distanceFilter = 10 // 每移動 10 公尺更新一次，省電
        manager.allowsBackgroundLocationUpdates = true // 允許背景更新
        manager.showsBackgroundLocationIndicator = true // 在手機頂部顯示藍色定位標籤，這能增加穩定性
        manager.pausesLocationUpdatesAutomatically = false // 不要自動暫停
    }

    func requestPermission() {
        manager.requestAlwaysAuthorization() // 要求「始終允許」定位
    }

    func startTracking() {
        trackPoints.removeAll() // 開始新紀錄時清空舊資料
        isTracking = true
        manager.startUpdatingLocation()
    }

    func stopTracking() {
        isTracking = false
        manager.stopUpdatingLocation()
    }

    // 衛星更新座標後的處理動作
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking, let location = locations.last else { return }
        
        // 只加入精確度小於 50 公尺的點，避免地圖亂跳
        if location.horizontalAccuracy < 50 {
            let coordinate = location.coordinate
            trackPoints.append(coordinate)
            print("紀錄新座標: \(coordinate.latitude), \(coordinate.longitude)")
        }
    }
}
