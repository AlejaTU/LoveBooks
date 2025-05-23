//
//  MainView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 19/5/25.
//

import SwiftUI
import FirebaseAuth


struct MainView: View {
    @Environment(AppState.self) var appState
    @State private var showAddReview = false
      @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 24) {
            TabView {
                        TimelineView()
                            .tabItem {
                                Label("Inicio", systemImage: "house")
                            }

                        BooksView()
                            .tabItem {
                                Label("Libros", systemImage: "book")
                            }

                        DiscoverView()
                            .tabItem {
                                Label("Descubre", systemImage: "network")
                            }

                        ProfileView()
                            .tabItem {
                                Label("Perfil", systemImage: "person.circle")
                            }
                    }
            /*
            Text("Bienvenido a LoveBooks 📚")
                      .font(.title)
                      .padding()

                  Button("Cerrar sesión") {
                      do {
                          try Auth.auth().signOut()
                          appState.authStatus = .loggedOut
                      } catch {
                          print("Error al cerrar sesión:", error.localizedDescription)
                      }
                  }
                  .foregroundStyle(.white)
                  .padding()
                  .background(Color.red)
                  .cornerRadius(10)
             */
              }
          }
      }

#Preview {
    MainView()
        .environment(AppState())
}
