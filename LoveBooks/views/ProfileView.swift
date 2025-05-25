//
//  ProfileView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 20/5/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfileView: View {
    @State private var showEditSheet = false
      @State private var showLogoutAlert = false
      @State private var userProfileVM = UserProfileViewModel()
    @Environment(AppState.self) var appState


      var body: some View {
          NavigationStack {
              ScrollView {
                  VStack(spacing: 16) {
                      // 📷 Foto de perfil
                      if let url = userProfileVM.profile?.photoURL, let imageURL = URL(string: url) {
                          AsyncImage(url: imageURL) { image in
                              image.resizable()
                          } placeholder: {
                              ProgressView()
                          }
                          .frame(width: 100, height: 100)
                          .clipShape(Circle())
                      } else {
                          Image("monkey")
                              .resizable()
                              .scaledToFill()
                              .frame(width: 100, height: 100)
                              .clipShape(Circle())
                              .shadow(radius: 4)
                      }


                      // 👤 Nombre de usuario
                      Text(userProfileVM.profile?.username ?? "Usuario")
                          .font(.title2)
                          .bold()

                      // 📝 Descripción
                      Text(userProfileVM.profile?.bio ?? "Aquí va la biografía del usuario.")
                          .font(.body)
                          .foregroundColor(.secondary)
                          .multilineTextAlignment(.center)
                          .padding(.horizontal)

                      // 🔢 Contadores
                      HStack(spacing: 24) {
                          VStack { Text("\(userProfileVM.profile?.followersCount ?? 0)").bold(); Text("Seguidores").font(.caption) }
                          VStack { Text("\(userProfileVM.profile?.followingCount ?? 0)").bold(); Text("Siguiendo").font(.caption) }
                          VStack { Text("\(userProfileVM.profile?.reviewsCount ?? 0)").bold(); Text("Reseñas").font(.caption) }
                          
                          
                      }
                      .padding(.top)
                     
                      // Aquí luego pondremos la lista de reseñas del usuario
                      Rectangle()
                          .fill(Color(.blue))
                          .frame(height: 5)
                          .padding(.horizontal, 32)
                          .padding(.top, 0)
                      
                  }
                  .padding()
                  
                  
                  
              }
              .navigationTitle("Mi Perfil")
              .toolbar {
                  ToolbarItem(placement: .navigationBarTrailing) {
                      Menu {
                          Button("Editar perfil") {
                              Task {
                                      await userProfileVM.fetchProfile()
                                      showEditSheet = true
                                  }                          }

                          Button("Cerrar sesión", role: .destructive) {
                              showLogoutAlert = true
                          }

                      } label: {
                          Image(systemName: "ellipsis.circle")
                      }
                  }
              }
              .task {
                  await userProfileVM.fetchProfile()
              }
              .alert("¿Cerrar sesión?", isPresented: $showLogoutAlert) {
                  Button("Cancelar", role: .cancel) {}
                  Button("Cerrar sesión", role: .destructive) {
                      do {
                          try Auth.auth().signOut()
                          appState.authStatus = .loggedOut
                      } catch {
                          print("❌ Error al cerrar sesión:", error.localizedDescription)
                      }
                  }
              }
              
          } .sheet(isPresented: $showEditSheet) {
              if let profile = userProfileVM.profile {
                  EditProfileView(
                      currentUsername: profile.username,
                      currentBio: profile.bio
                  )
                  .environment(userProfileVM)
              }
          }
          .onChange(of: showEditSheet) { isPresented in
              if !isPresented {
                  Task {
                      await userProfileVM.fetchProfile()
                  }
              }
          }
          }
      
  }
#Preview {
    ProfileView()
        .environment(AppState())
}
