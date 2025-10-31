import Foundation
import CoreLocation

struct ExploredCell: Identifiable, Codable, Equatable {
    let id: String
    let latitude: Double
    let longitude: Double
    let exploredAt: Date

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(id: String, latitude: Double, longitude: Double, exploredAt: Date = Date()) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.exploredAt = exploredAt
    }
}

extension ExploredCell {
    static var mock: ExploredCell {
        ExploredCell(
            id: "lat_52.520_lng_13.405",
            latitude: 52.520,
            longitude: 13.405,
            exploredAt: Date()
        )
    }

    static var mockArray: [ExploredCell] {
        [
            ExploredCell(id: "lat_52.520_lng_13.405", latitude: 52.520, longitude: 13.405),
            ExploredCell(id: "lat_52.521_lng_13.406", latitude: 52.521, longitude: 13.406),
            ExploredCell(id: "lat_52.522_lng_13.407", latitude: 52.522, longitude: 13.407)
        ]
    }
}
