//
//  LocationViewModel.swift
//  LocationViewModel
//
//  Created by Rafael Fernandez Alvarez on 21/9/21.
//

import Foundation
import MapKit

@MainActor
class LocationViewModel: ObservableObject {
    private static let meters: CLLocationDistance = 500
    
    @Published var coordinateRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.4086928904728, longitude: -5.944729857887718), latitudinalMeters: LocationViewModel.meters, longitudinalMeters: LocationViewModel.meters)
    @Published var userPoint: UserPoint?
    @Published var isLocationMonitoring = false
    
    lazy var locationMonitor = LocationMonitor()
    
    func handleLocation() {
        if isLocationMonitoring {
            stopLocation()
        } else {
            Task {
                await startLocation()
            }
        }
    }
    
    func startLocation() async {
        defer {
            print("[LocationViewModel] StartLocation - Finish")
            isLocationMonitoring = false
        }
        do {
            isLocationMonitoring = true
            let locations = try await locationMonitor.start()
            for await location in locations {
                userPoint = UserPoint(coordinate: location.coordinate)
                coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: LocationViewModel.meters, longitudinalMeters: LocationViewModel.meters)
            }
            print("[LocationViewModel] StartLocation - For terminado")
        } catch {
            print("[LocationViewModel] StartLocation - Error: \(error.localizedDescription)")
        }
    }
    
    func stopLocation() {
        defer { print("[LocationViewModel] StopLocation") }
        isLocationMonitoring = false
        locationMonitor.stop()
    }
    
}

struct UserPoint: Identifiable {
    var coordinate: CLLocationCoordinate2D
    var id: UUID = UUID()
}
