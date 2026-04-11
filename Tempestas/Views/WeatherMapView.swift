//
//  WeatherMapView.swift
//  Tempestas
//

import SwiftUI
import MapKit

// MARK: - WeatherMapView

struct WeatherMapView: View {
    let location: WeatherLocation

    @State private var selectedLayer: WeatherMapLayer = .precipitation

    var body: some View {
        ZStack(alignment: .bottom) {
            MapKitView(location: location, selectedLayer: selectedLayer)
                .ignoresSafeArea(edges: .bottom)

            VStack(alignment: .leading, spacing: 0) {
                MapLegendView(layer: selectedLayer)
                    .padding(.leading, 16)
                    .padding(.bottom, 8)

                layerPicker
            }
        }
    }

    // MARK: - Subviews

    private var layerPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(WeatherMapLayer.allCases) { layer in
                    Button {
                        selectedLayer = layer
                    } label: {
                        Label(layer.displayName, systemImage: layer.sfSymbol)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedLayer == layer ? Color.blue : Color(.systemBackground))
                            .foregroundColor(selectedLayer == layer ? .white : .primary)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - MapKitView (UIViewRepresentable)

struct MapKitView: UIViewRepresentable {
    let location: WeatherLocation
    let selectedLayer: WeatherMapLayer

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false

        let coordinate = CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude
        )
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 600_000,
            longitudinalMeters: 600_000
        )
        mapView.setRegion(region, animated: false)
        addOverlay(to: mapView, coordinator: context.coordinator)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        guard context.coordinator.currentLayer != selectedLayer else { return }
        context.coordinator.currentLayer = selectedLayer
        mapView.removeOverlays(mapView.overlays.filter { $0 is WeatherMapTileOverlay })
        addOverlay(to: mapView, coordinator: context.coordinator)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func addOverlay(to mapView: MKMapView, coordinator: Coordinator) {
        let overlay = WeatherMapTileOverlay(layer: selectedLayer)
        overlay.canReplaceMapContent = false
        mapView.addOverlay(overlay, level: .aboveLabels)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, MKMapViewDelegate {
        var currentLayer: WeatherMapLayer = .precipitation

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let tileOverlay = overlay as? WeatherMapTileOverlay else {
                return MKOverlayRenderer(overlay: overlay)
            }
            let renderer = MKTileOverlayRenderer(tileOverlay: tileOverlay)
            renderer.alpha = 0.75
            return renderer
        }
    }
}

// MARK: - MapLegendView

struct MapLegendView: View {
    let layer: WeatherMapLayer

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(layer.displayName)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            LinearGradient(
                colors: layer.legendGradient,
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 120, height: 8)
            .cornerRadius(4)

            HStack {
                Text(layer.legendMinLabel)
                Spacer()
                Text(layer.legendMaxLabel)
            }
            .frame(width: 120)
            .font(.caption2)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
    }
}

// MARK: - WeatherMapTileOverlay

class WeatherMapTileOverlay: MKTileOverlay {
    let mapLayer: WeatherMapLayer

    init(layer: WeatherMapLayer) {
        self.mapLayer = layer
        super.init(urlTemplate: "https://tile.openweathermap.org/map/\(layer.rawValue)/{z}/{x}/{y}.png?appid=\(WeatherMapService.apiKey)")
        tileSize = CGSize(width: 256, height: 256)
    }

}
