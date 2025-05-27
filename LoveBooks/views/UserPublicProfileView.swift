//
//  UserPublicProfileView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 27/5/25.
//
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import SwiftUI

struct UserPublicProfileView: View {
    let userID: String

    @State private var userProfile: UserProfile?
    @State private var userReviews: [Review] = []
    @State private var isLoading = true
    @State private var followsVM = FollowsViewModel()

    var body: some View {
        ScrollView {
            if let profile = userProfile {
                VStack(spacing: 16) {
                    // 📷 Foto de perfil
                    if let url = URL(string: profile.photoURL ?? "") {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                    } else {
                        Image("monkey")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    }

                    // 👤 Nombre + bio
                    Text(profile.username).font(.title2).bold()
                    Text(profile.bio).font(.body).foregroundColor(.secondary)

                    // 🔘 Botón de seguir / siguiendo
                    if let currentUID = Auth.auth().currentUser?.uid, currentUID != userID {
                        if followsVM.isFollowing(userID: userID) {
                            Button("Siguiendo") {
                                Task {
                                    await followsVM.unfollowUser(userIDToUnfollow: userID)
                                    await followsVM.fetchFollowedItems()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.gray)
                        } else {
                            Button("Seguir") {
                                Task {
                                    await followsVM.followUser(userIDToFollow: userID)
                                    await followsVM.fetchFollowedItems()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                        }
                    }

                    Divider()

                    // 📚 Lista de reseñas
                    ForEach(userReviews) { review in
                        VStack(alignment: .leading) {
                            Text(review.title).font(.headline)
                            Text(review.content).font(.body)
                            Text(review.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                    }
                }
                .padding()
            } else {
                ProgressView("Cargando perfil...")
            }
        }
        .navigationTitle("Perfil")
        .task {
            await loadData()
        }
    }

    func loadData() async {
        isLoading = true
        let db = Firestore.firestore()
        do {
            let doc = try await db.collection("users").document(userID).getDocument()
            userProfile = try doc.data(as: UserProfile.self)

            let reviewsSnapshot = try await db.collection("reviews")
                .whereField("userID", isEqualTo: userID)
                .order(by: "date", descending: true)
                .getDocuments()

            userReviews = try reviewsSnapshot.documents.compactMap {
                try $0.data(as: Review.self)
            }

            await followsVM.fetchFollowedItems()
        } catch {
            print("❌ Error al cargar datos:", error.localizedDescription)
        }
        isLoading = false
    }
}

#Preview {
    UserPublicProfileView(userID: "PREVIEW_USER_ID")
}
