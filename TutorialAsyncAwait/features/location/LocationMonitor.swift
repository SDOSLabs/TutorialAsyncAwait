//
//  LocationMonitor.swift
//  LocationMonitor
//
//  Created by Rafael Fernandez Alvarez on 21/9/21.
//

import Foundation
import CoreLocation

@MainActor
class LocationMonitor: NSObject {
    enum LocationError: Error {
        case permissionDenied
    }
    
    private var permissionContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    var locationHandler: (CLLocation?) -> Void = { _ in }
    
    nonisolated private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    
    func start() async throws -> AsyncStream<CLLocation> {
        switch await requestPermission() {
        case .authorizedAlways, .authorizedWhenInUse:
            let locations = AsyncStream(CLLocation.self) { continuation in
                continuation.onTermination = { @Sendable _ in
                    self.locationManager.stopUpdatingLocation()
                    print("[LocationMonitor] Continuation - Termination")
                }
                locationHandler = { location in
                    if let location = location {
                        print("[LocationMonitor] Continuation - New Location")
                        continuation.yield(location)
                    } else {
                        print("[LocationMonitor] Continuation - Finish")
                        continuation.finish()
                    }
                }
                locationManager.startUpdatingLocation()
            }
            return locations
        default:
            print("[LocationMonitor] - Disable location permissions")
            throw LocationError.permissionDenied
        }
    }
    
    func stop() {
        locationHandler(nil)
    }
    
    private func requestPermission() async -> CLAuthorizationStatus {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                permissionContinuation = continuation
                locationManager.requestWhenInUseAuthorization()
            }
        default:
            return locationManager.authorizationStatus
        }
    }
}

extension LocationMonitor: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            break
        default:
            permissionContinuation?.resume(returning: manager.authorizationStatus)
            permissionContinuation = nil //Se debe eliminar `permissionContinuation` ya que solo se puede llamar a `.resume` una única vez
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationHandler(location)
        }
    }
}
