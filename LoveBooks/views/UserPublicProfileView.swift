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
    @State private var userProfileVM = UserProfileViewModel()


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

                    // datos
                    Text(profile.username).font(.title2).bold()
                    Text(profile.bio).font(.body).foregroundColor(.secondary)
                    HStack(spacing: 24) {
                        VStack {
                            Text("\(userProfileVM.profile?.followersCount ?? 0)").bold()
                            Text("Seguidores").font(.caption)
                        }
                        VStack {
                            Text("\(userProfileVM.profile?.followingCount ?? 0)").bold()
                            Text("Siguiendo").font(.caption)
                        }
                        VStack {
                            Text("\(userProfileVM.profile?.reviewsCount ?? 0)").bold()
                            Text("Reseñas").font(.caption)
                        }
                    }
                 

                    Divider()

                    //  Lista de reseñas
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let currentUID = Auth.auth().currentUser?.uid, currentUID != userID {
                    Button {
                        Task {
                            if followsVM.isFollowing(userID: userID) {
                                await followsVM.unfollowUser(userIDToUnfollow: userID)
                            } else {
                                await followsVM.followUser(userIDToFollow: userID)
                            }
                            await followsVM.fetchFollowedItems()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: followsVM.isFollowing(userID: userID) ? "checkmark.circle.fill" : "plus.circle")
                            Text(followsVM.isFollowing(userID: userID) ? "Siguiendo" : "Seguir")
                        }
                        .font(.subheadline.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundColor(.white)
                        .background(followsVM.isFollowing(userID: userID) ? Color.gray : Color.blue)
                        .clipShape(Capsule())
                        .shadow(radius: 2)
                        .animation(.easeInOut(duration: 0.2), value: followsVM.isFollowing(userID: userID))
                    }
                }
            }
        }

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
