//
//  TutorialAsyncAwaitApp.swift
//  TutorialAsyncAwait
//
//  Created by Rafael Fernandez Alvarez on 16/9/21.
//

import SwiftUI

@main
struct TutorialAsyncAwaitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            TabView {
                ListTestView()
                    .tabItem {
                        Label("Test", systemImage: "testtube.2")
                    }
                ListProductView()
                    .tabItem {
                        Label("List", systemImage: "list.dash")
                    }
                LocationView()
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
            }
        }
    }
}
