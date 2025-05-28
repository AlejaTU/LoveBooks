//
//  TimelineView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 20/5/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct TimelineView: View {
    @State private var reviews: [Review] = []
    @State private var showAddSheet = false
    @State private var followsVM = FollowsViewModel()
    @State private var showReplySheet = false
    @State private var selectedReview: Review?
    @State private var expandedReviewIDs: Set<String> = []
    @State private var repliesVM = RepliesVM()


    var body: some View {
        NavigationStack {
            ZStack {
                Color(.whitebreak).ignoresSafeArea()

                if reviews.isEmpty {
                    Text("No sigues a nadie.")
                        .foregroundColor(.gray)
                        .font(.headline)
                } else {
                    List(reviews) { review in
                        ReviewThreadView(
                            review: review,
                            expandedReviewIDs: $expandedReviewIDs,
                            repliesByReview: $repliesVM.repliesByReview,
                            onReplyTapped: {
                                selectedReview = review
                                showReplySheet = true
                            }
                        )
                        .task {
                            await loadReplies(for: review.id ?? "")
                        }
                    }
                    .listStyle(.plain)
                }

                // ➕ Botón flotante
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showAddSheet = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Para Ti")
            .sheet(isPresented: $showAddSheet) {
                
            }
            .sheet(isPresented: $showReplySheet) {
                if let review = selectedReview {
                    ReplySheetView(parentReviewID: review.id ?? "")
                }
            }
            .task {
                await loadTimelineReviews()
            }
        }
    }

    //  carga las reseñas del timeline del usuario actual
    func loadTimelineReviews() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        do {
            let snapshot = try await db.collection("users").document(uid).collection("timeline")
                .order(by: "date", descending: true)
                .getDocuments()

            let timelineReviews = snapshot.documents.compactMap { doc -> Review? in
                let data = doc.data()
                return Review(
                    id: data["reviewID"] as? String,
                    userID: data["userID"] as? String ?? "",
                    bookID: data["bookID"] as? String,
                    bookTitle: data["bookTitle"] as? String,
                    title: data["title"] as? String ?? "",
                    content: data["content"] as? String ?? "",
                    date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                    username: data["username"] as? String,
                    photoURL: data["photoURL"] as? String
                )
            }

            self.reviews = timelineReviews
        } catch {
            print("❌ Error cargando timeline:", error.localizedDescription)
        }
    }

    func loadReplies(for reviewID: String) async {
        if repliesVM.repliesByReview[reviewID] != nil {
            return // ya se cargaron
        }

        let db = Firestore.firestore()
        do {
            let snapshot = try await db.collection("replies")
                .whereField("parentID", isEqualTo: reviewID)
                .order(by: "date", descending: false)
                .limit(to: 10)
                .getDocuments()

            let replies = snapshot.documents.compactMap { doc -> Reply? in
                let data = doc.data()
                return Reply(
                    id: data["id"] as? String ?? UUID().uuidString,
                    parentID: data["parentID"] as? String ?? "",
                    userID: data["userID"] as? String ?? "",
                    content: data["content"] as? String ?? "",
                    date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                    username: data["username"] as? String ?? "Usuario",
                    photoURL: data["photoURL"] as? String
                )
            }

            repliesVM.repliesByReview[reviewID] = replies
        } catch {
            print("❌ Error cargando respuestas: \(error.localizedDescription)")
        }
    }
}


#Preview {
    TimelineView()
        
}
