import Foundation
import CoreLocation

struct GridCalculator {
    static let gridSize: Double = 50.0
    static let earthRadiusMeters: Double = 6_371_000.0

    static func quantize(_ value: Double, gridSize: Double) -> Double {
        let gridDegrees = metersToLatitudeDegrees(gridSize)
        return (value / gridDegrees).rounded() * gridDegrees
    }

    static func metersToLatitudeDegrees(_ meters: Double) -> Double {
        return meters / earthRadiusMeters * (180.0 / .pi)
    }

    static func metersToLongitudeDegrees(_ meters: Double, atLatitude latitude: Double) -> Double {
        let latitudeRadians = latitude * .pi / 180.0
        return meters / (earthRadiusMeters * cos(latitudeRadians)) * (180.0 / .pi)
    }

    static func cellsWithinRadius(
        center: CLLocationCoordinate2D,
        radiusMeters: Double = 150.0
    ) -> [GridCell] {
        let cellsInRadius = Int(ceil(radiusMeters / gridSize))
        var cells: [GridCell] = []

        for latOffset in -cellsInRadius...cellsInRadius {
            for lngOffset in -cellsInRadius...cellsInRadius {
                let offsetCoord = offsetCoordinate(
                    center,
                    latMeters: Double(latOffset) * gridSize,
                    lngMeters: Double(lngOffset) * gridSize
                )

                let distance = haversineDistance(from: center, to: offsetCoord)
                if distance <= radiusMeters {
                    cells.append(GridCell(coordinate: offsetCoord))
                }
            }
        }

        return cells
    }

    static func haversineDistance(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) -> Double {
        let lat1 = from.latitude * .pi / 180.0
        let lon1 = from.longitude * .pi / 180.0
        let lat2 = to.latitude * .pi / 180.0
        let lon2 = to.longitude * .pi / 180.0

        let dLat = lat2 - lat1
        let dLon = lon2 - lon1

        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1) * cos(lat2) *
                sin(dLon / 2) * sin(dLon / 2)

        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return earthRadiusMeters * c
    }

    static func offsetCoordinate(
        _ coord: CLLocationCoordinate2D,
        latMeters: Double,
        lngMeters: Double
    ) -> CLLocationCoordinate2D {
        let latOffset = metersToLatitudeDegrees(latMeters)
        let lngOffset = metersToLongitudeDegrees(lngMeters, atLatitude: coord.latitude)

        return CLLocationCoordinate2D(
            latitude: coord.latitude + latOffset,
            longitude: coord.longitude + lngOffset
        )
    }
}
