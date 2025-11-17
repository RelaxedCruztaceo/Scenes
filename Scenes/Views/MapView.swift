//
//  MapView.swift
//  Scenes
//
//  Created by Manuel Alejandro Cruz Valladares on 07/11/25.
//

// MovieLocationsApp
// A simple SwiftUI + MapKit app showing film shooting locations

import SwiftUI
import MapKit
import CoreLocation
internal import Combine

struct MovieLocation: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let movie: String
    let coordinate: CLLocationCoordinate2D
    let symbol: String
    
    static func == (lhs: MovieLocation, rhs: MovieLocation) -> Bool {
    return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    }
}

class MovieLocationsViewModel: ObservableObject {
    @Published var camera: MapCameraPosition = .automatic
    @Published var selectedLocation: MovieLocation? = nil

    @Published var locations: [MovieLocation] = [
        MovieLocation(title: "Reggia di Caserta", movie: "Star Wars: Episode I", coordinate: .casertaPalace, symbol: "film"),
        MovieLocation(title: "Antica Pizzeria da Michele", movie: "Eat Pray Love", coordinate: .pizzeriaDaMichele, symbol: "fork.knife"),
        MovieLocation(title: "Teatro di San Carlo", movie: "The Talented Mr. Ripley", coordinate: .teatroSanCarlo, symbol: "theatermasks.fill"),
        MovieLocation(title: "Galleria Principe di Napoli", movie: "Gomorrah", coordinate: .galleriaPrincipe, symbol: "building.columns.fill")
    ]

    func centerOnNaples() {
        let center = CLLocationCoordinate2D(latitude: 40.8518, longitude: 14.2681)
        let span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        let region = MKCoordinateRegion(center: center, span: span)
        camera = .region(region)
    }
}

struct MapView: View {
    @StateObject private var viewModel = MovieLocationsViewModel()

    var body: some View {
        Map(position: $viewModel.camera) {
            ForEach(viewModel.locations) { location in
                Annotation(location.title, coordinate: location.coordinate) {
                    Image(systemName: location.symbol)
                        .imageScale(.medium)
                        .foregroundStyle(.brown)
                        .padding(5)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                        .onTapGesture {
                            viewModel.selectedLocation = location
                        }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .onAppear {
            viewModel.centerOnNaples()
        }
        .sheet(item: $viewModel.selectedLocation) { location in
            MovieLocationDetailView(location: location)
                .presentationDetents([.height(300)])
        }
    }
}

struct MovieLocationDetailView: View {
    let location: MovieLocation

    var body: some View {
        VStack(spacing: 16) {
            Text(location.title)
                .font(.title)
                .bold()

            Text("Featured in: \(location.movie)")
                .font(.title3)
                .foregroundColor(.secondary)

            Divider()
            Map(coordinateRegion: .constant(
                MKCoordinateRegion(center: location.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            ))
            .frame(height: 150)
            .cornerRadius(12)
        }
        .padding()
    }
}

extension CLLocationCoordinate2D {
    static let galleriaPrincipe = CLLocationCoordinate2D(latitude: 40.85244400007876, longitude: 14.250337387046514)
    static let casertaPalace = CLLocationCoordinate2D(latitude: 41.0732, longitude: 14.3271)
    static let pizzeriaDaMichele = CLLocationCoordinate2D(latitude: 40.84976211067139, longitude: 14.26329614054348)
    static let teatroSanCarlo = CLLocationCoordinate2D(latitude: 40.83753125683363, longitude: 14.249615110983303)
}

#Preview {
    MapView()
}
