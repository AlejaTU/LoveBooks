//
//  SplashView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 19/5/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore

struct SplashView: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack {
                Spacer()
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if Auth.auth().currentUser != nil {
                    appState.authStatus = .loggedIn
                } else {
                    appState.authStatus = .loggedOut
                }
            }
        }
    }
}

#Preview {
    SplashView()
        .environment(AppState())
        
}
