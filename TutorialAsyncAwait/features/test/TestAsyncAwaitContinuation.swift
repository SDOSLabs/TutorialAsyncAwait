//
//  TestAsyncAwaitContinuation.swift
//  TutorialAsyncAwait
//
//  Created by Rafael Fernandez Alvarez on 23/9/21.
//

import Foundation
import CoreLocation
import UserNotifications

class TestAsyncAwaitContinuation: NSObject, Testable {
    static let shared = TestAsyncAwaitContinuation()
    private override init() { }
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    private var locationPermissionContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    
    public func start() {
        print("[TestAsyncAwaitContinuation] Start")
        
        Task {
            await getNotificationPushPermissions()
            await getLocationPermission()
        }
    }
    
    private func getNotificationPushPermissions() async {
        defer { print("[TestAsyncAwaitContinuation] Notification - Finish") }
        
        do {
            let result = try await requestNotificationPushPermissions()
            print("[TestAsyncAwaitContinuation] Notification - Has Permissions: \(result)")
        } catch {
            print("[TestAsyncAwaitContinuation] Notification - Error: \(error)")
        }
    }
    
    @MainActor
    private func requestNotificationPushPermissions() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    private func getLocationPermission() async {
        defer { print("[TestAsyncAwaitContinuation] LocationManager - Finish") }
        
        switch await requestLocationPermission() {
        case .denied:
            print("[TestAsyncAwaitContinuation] LocationManager - didChangeAuthorization denied")
        case .notDetermined:
            print("[TestAsyncAwaitContinuation] LocationManager - didChangeAuthorization notDetermined")
        case .authorizedWhenInUse:
            print("[TestAsyncAwaitContinuation] LocationManager - didChangeAuthorization authorizedWhenInUse")
        case .authorizedAlways:
            print("[TestAsyncAwaitContinuation] LocationManager - didChangeAuthorization authorizedAlways")
        case .restricted:
            print("[TestAsyncAwaitContinuation] LocationManager - didChangeAuthorization restricted")
        default:
            print("[TestAsyncAwaitContinuation] LocationManager - didChangeAuthorization")
        }
    }
    
    @MainActor
    private func requestLocationPermission() async -> CLAuthorizationStatus {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                locationPermissionContinuation = continuation
                locationManager.requestWhenInUseAuthorization()
            }
        default:
            return locationManager.authorizationStatus
        }
    }
    
}

extension TestAsyncAwaitContinuation: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            break
        default:
            locationPermissionContinuation?.resume(returning: manager.authorizationStatus)
            locationPermissionContinuation = nil //Se debe eliminar `locationPermissionContinuation` ya que solo se puede llamar a `.resume` una única vez
        }
    }
}
