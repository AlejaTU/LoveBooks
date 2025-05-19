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
    @State private var isActive = false
    @State private var isCheckingAuth = true
    @State private var isAuthenticated = false
    
    
    private func checkAuth() async {
        // Espera 2 segundos para mostrar el logo
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        // Comprueba si hay un usuario logueado
        let user = Auth.auth().currentUser
        isAuthenticated = user != nil
        isCheckingAuth = false
    }
    var body: some View {
        Group {
            if isCheckingAuth {
                // Pantalla de splash con logo
                VStack {
                    Spacer()
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .onAppear {
                    Task {
                        await checkAuth()
                    }
                }
            } else {
                if isAuthenticated {
                    MainView()
                } else {
                    LoginView()
                }
            }
        }
    }
}

#Preview {
    SplashView()
        
}
