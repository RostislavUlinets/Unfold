import SwiftUI

struct FogCellView: View {
    let cell: GridCell
    @EnvironmentObject var mapController: MapController

    var isExplored: Bool {
        mapController.exploredCells.contains(cell.cellId)
    }

    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .frame(width: 50, height: 50)
            .opacity(isExplored ? 0.0 : 0.8)
            .animation(.easeOut(duration: 1.0), value: isExplored)
    }
}
