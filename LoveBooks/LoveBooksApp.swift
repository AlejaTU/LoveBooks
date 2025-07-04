//
//  LoveBooksApp.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 14/5/25.
//

import SwiftUI

import UIKit
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
@main
struct LoveBooksApp: App {
    // register app delegate for Firebase setup
      @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                            switch appState.authStatus {
                            case .checking:
                                SplashView()
                            case .loggedOut:
                                LoginView()
                            case .loggedIn:
                                MainView()
                            }
                        }.environment(appState)

        }
    }
}
