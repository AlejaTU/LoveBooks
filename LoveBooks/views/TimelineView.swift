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
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("#FAF8F4").ignoresSafeArea()
                
                if reviews.isEmpty {
                    Text("No sigues a nadie.")
                        .foregroundColor(.gray)
                        .font(.headline)
                } else {
                    List(reviews) { review in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(review.title)
                                .font(.headline)
                            Text(review.content)
                                .font(.body)
                                .lineLimit(3)
                            Text(review.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                    .listStyle(.plain)
                }
                
                // Botón flotante
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
            .navigationTitle("Reseñas")
            .sheet(isPresented: $showAddSheet) {
                /*AddReviewView(onReviewAdded: { newReview in
                 reviews.insert(newReview, at: 0) // Muestra la nueva primero
                 })
                 */
            }
            .onAppear {
                loadReviews()
            }.task {
                await followsVM.fetchFollowedItems()
            }
        }
    }
    
    func loadReviews() {
        let db = Firestore.firestore()
        
        // Si no seguimos a nadie, no hacemos consulta
        guard !followsVM.followedUsers.isEmpty || !followsVM.followedBooks.isEmpty else {
            self.reviews = []
            return
        }
        
        var reviewsFromUsers: [Review] = []
        var reviewsFromBooks: [Review] = []
        
        let group = DispatchGroup()
        
        // 🔹 Consultar reseñas de usuarios que sigo
        if !followsVM.followedUsers.isEmpty {
            group.enter()
            db.collection("reviews")
                .whereField("userID", in: followsVM.followedUsers)
                .getDocuments { snapshot, error in
                    if let snapshot = snapshot {
                        reviewsFromUsers = snapshot.documents.compactMap {
                            try? $0.data(as: Review.self)
                        }
                    }
                    group.leave()
                }
        }
        
        // 🔹 Consultar reseñas de libros que sigo
        if !followsVM.followedBooks.isEmpty {
            group.enter()
            db.collection("reviews")
                .whereField("bookID", in: followsVM.followedBooks)
                .getDocuments { snapshot, error in
                    if let snapshot = snapshot {
                        reviewsFromBooks = snapshot.documents.compactMap {
                            try? $0.data(as: Review.self)
                        }
                    }
                    group.leave()
                }
        }
        
        group.notify(queue: .main) {
            let all = (reviewsFromUsers + reviewsFromBooks)
                .sorted(by: { $0.date > $1.date })
            
            self.reviews = all
        }
    }
    
}


#Preview {
    TimelineView()
        
}
