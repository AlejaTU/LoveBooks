//
//  AppState.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 19/5/25.
//

import Foundation
import SwiftUI




@MainActor
@Observable
final class AppState {
    enum AuthStatus {
            case checking // mientras mostramos Splash
            case loggedOut
            case loggedIn
        }

        var authStatus: AuthStatus = .checking
}
