//
//  DiscoverUsersView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 27/5/25.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct DiscoverUsersView: View {
    @State private var searchText = ""
       @State private var users: [UserSearchResult] = []
       @State private var isSearching = false
    let currentUserID = Auth.auth().currentUser?.uid


       var body: some View {
           NavigationStack {
               VStack {
                   TextField("Buscar usuarios...", text: $searchText)
                       .padding()
                       .textFieldStyle(.roundedBorder)
                       .onChange(of: searchText) { _ in
                           Task { await fetchUsers() }
                       }

                   if users.isEmpty {
                       Text("No se encontraron usuarios")
                           .foregroundColor(.gray)
                           .padding()
                   } else {
                       List(users) { user in
                           NavigationLink {
                               UserPublicProfileView(userID: user.id)
                           } label: {
                               HStack {
                                   if let url = user.photoURL, let imageURL = URL(string: url) {
                                       AsyncImage(url: imageURL) { image in
                                           image.resizable()
                                       } placeholder: {
                                           ProgressView()
                                       }
                                       .frame(width: 40, height: 40)
                                       .clipShape(Circle())
                                   } else {
                                       Image(systemName: "person.crop.circle")
                                           .resizable()
                                           .frame(width: 40, height: 40)
                                           .foregroundColor(.gray)
                                   }

                                   Text(user.username)
                                       .font(.body)
                               }
                           }
                       }
                       .listStyle(.plain)
                   }
               }
               .navigationTitle("Buscar usuarios")
               .task {
                   await fetchUsers()  // Carga inicial
               }
           }
       }

       func fetchUsers() async {
           let db = Firestore.firestore()
           do {
               if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                   // Mostrar usuarios recientes
                   let snapshot = try await db.collection("users")
                       .order(by: "username")
                       .limit(to: 20)
                       .getDocuments()

                   users = snapshot.documents.compactMap { doc in
                                   if doc.documentID == currentUserID { return nil } // excluir actual
                                   let data = doc.data()
                                   guard let username = data["username"] as? String else { return nil }
                                   let photoURL = data["photoURL"] as? String
                                   return UserSearchResult(id: doc.documentID, username: username, photoURL: photoURL)
                               }
               } else {
                   // Buscar coincidencias por nombre
                   let snapshot = try await db.collection("users")
                       .whereField("username", isGreaterThanOrEqualTo: searchText.lowercased())
                       .whereField("username", isLessThanOrEqualTo: searchText.lowercased() + "\u{f8ff}")
                       .limit(to: 10)
                       .getDocuments()

                   users = snapshot.documents.compactMap { doc in
                       let data = doc.data()
                       guard let username = data["username"] as? String else { return nil }
                       let photoURL = data["photoURL"] as? String
                       return UserSearchResult(id: doc.documentID, username: username, photoURL: photoURL)
                   }
               }
           } catch {
               print("❌ Error al cargar usuarios: \(error.localizedDescription)")
           }
       }
   }
#Preview {
    DiscoverUsersView()
}
