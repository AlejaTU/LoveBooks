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
    @State private var expandedReviewIDs: Set<String> = []
    @State private var repliesVM = RepliesVM()
    @State private var showReplySheet = false
    @State private var selectedReview: Review?
    
    
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
                        ReviewThreadView(
                            review: review,
                            expandedReviewIDs: $expandedReviewIDs,
                            repliesByReview: $repliesVM.repliesByReview,
                            onReplyTapped: {
                                selectedReview = review
                                showReplySheet = true
                            }
                        )
                    }
                    .sheet(isPresented: $showReplySheet) {
                        if let review = selectedReview {
                            ReplySheetView(parentReviewID: review.id ?? "")
                        }
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
                            await userProfileVM.fetchProfile(for: userID)
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
            await userProfileVM.fetchProfile(for: userID)
            await loadData()
            for review in userReviews {
                await repliesVM.loadReplies(for: review.id ?? "")
            }
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
            
            var enrichedReviews: [Review] = []
            
            for doc in reviewsSnapshot.documents {
                var review = try doc.data(as: Review.self)
                
                if let bookID = review.bookID {
                    let bookDoc = try await db.collection("books").document(bookID).getDocument()
                    review.bookTitle = bookDoc["title"] as? String
                }
                
                enrichedReviews.append(review)
            }
            
            userReviews = enrichedReviews
            
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
