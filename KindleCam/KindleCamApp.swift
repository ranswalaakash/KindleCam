//
//  KindleCamApp.swift
//  KindleCam
//
//  Created by Aakash Singh Ranswal on 28/07/26.
//

import SwiftUI
import SwiftData

public final class AppDelegate: NSObject, UIApplicationDelegate {
    public static var orientationLock: UIInterfaceOrientationMask = .all

    public func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

@main
struct KindleCamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var sharedModelContainer: ModelContainer = AppModelContainer.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
