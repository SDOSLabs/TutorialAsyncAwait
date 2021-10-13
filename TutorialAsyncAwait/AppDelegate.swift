//
//  AppDelegate.swift
//  AppDelegate
//
//  Created by Rafael Fernandez Alvarez on 16/9/21.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    var task: Task<(), Never>?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        observeDidBecomeActive()
        Task {
            await Task.sleep(10 * 1_000_000_000) // Wait one seconds
            self.task?.cancel()
        }
        return true
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(notificatinoDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func unregisterNotification() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func notificatinoDidBecomeActive(_ notification: Notification) {
        print("didBecomeActiveNotification")
    }
    
    private func observeDidBecomeActive() {
        print("[AppDelegate] - Start")
        self.task = Task {
            defer { print("[AppDelegate] - Finish") }
            let notifications = NotificationCenter.default.notifications(named: UIApplication.didBecomeActiveNotification)
            for await notification in notifications {
                print("[AppDelegate] - didBecomeActiveNotification")
            }
        }
    }
}
