import Foundation
import CoreLocation

struct GridCell: Hashable, Codable {
    let cellId: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(coordinate: CLLocationCoordinate2D, gridSize: Double = 50.0) {
        let quantizedLat = Self.quantize(coordinate.latitude, gridSize: gridSize)
        let quantizedLng = Self.quantize(coordinate.longitude, gridSize: gridSize)

        self.latitude = quantizedLat
        self.longitude = quantizedLng
        self.cellId = "lat_\(String(format: "%.3f", quantizedLat))_lng_\(String(format: "%.3f", quantizedLng))"
    }

    init(cellId: String, latitude: Double, longitude: Double) {
        self.cellId = cellId
        self.latitude = latitude
        self.longitude = longitude
    }

    private static func quantize(_ value: Double, gridSize: Double) -> Double {
        let earthRadiusMeters: Double = 6_371_000.0
        let gridDegrees = gridSize / earthRadiusMeters * (180.0 / .pi)
        return (value / gridDegrees).rounded() * gridDegrees
    }
}

extension GridCell {
    static var mock: GridCell {
        GridCell(
            coordinate: CLLocationCoordinate2D(latitude: 52.520, longitude: 13.405),
            gridSize: 50.0
        )
    }

    static var mockArray: [GridCell] {
        [
            GridCell(coordinate: CLLocationCoordinate2D(latitude: 52.520, longitude: 13.405)),
            GridCell(coordinate: CLLocationCoordinate2D(latitude: 52.521, longitude: 13.406)),
            GridCell(coordinate: CLLocationCoordinate2D(latitude: 52.522, longitude: 13.407))
        ]
    }
}
