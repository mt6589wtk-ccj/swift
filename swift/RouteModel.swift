import Foundation
import SwiftData
import CoreLocation

@Model
class SavedRoute {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var latitudes: [Double] // 儲存緯度陣列
    var longitudes: [Double] // 儲存經度陣列
    
    init(startTime: Date = Date(), latitudes: [Double] = [], longitudes: [Double] = []) {
        self.id = UUID()
        self.startTime = startTime
        self.latitudes = latitudes
        self.longitudes = longitudes
    }
    
    // 輔助工具：將存儲的數值轉回地圖座標陣列
    var coordinates: [CLLocationCoordinate2D] {
        return zip(latitudes, longitudes).map { CLLocationCoordinate2D(latitude: $0, longitude: $1) }
    }
}
