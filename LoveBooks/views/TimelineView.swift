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
                           VStack(alignment: .leading, spacing: 8) {
                               HStack(alignment: .center, spacing: 8) {
                                           if let urlString = review.photoURL,
                                              let url = URL(string: urlString) {
                                               AsyncImage(url: url) { image in
                                                   image.resizable().scaledToFill()
                                               } placeholder: {
                                                   Circle().fill(Color.gray.opacity(0.3))
                                               }
                                               .frame(width: 36, height: 36)
                                               .clipShape(Circle())
                                           } else {
                                               Circle()
                                                   .fill(Color.gray.opacity(0.3))
                                                   .frame(width: 36, height: 36)
                                           }

                                           Text(review.username ?? "Usuario desconocido")
                                               .font(.subheadline)
                                               .bold()
                                       }
                               //  Título del libro si existe
                               if !review.title.isEmpty {
                                   HStack {
                                       Text(review.title)
                                           .font(.subheadline)
                                           .foregroundColor(.blue)
                                           .lineLimit(1)
                                           .truncationMode(.tail)

                                       Spacer()

                                       Button {
                                           selectedReview = review
                                           showReplySheet = true
                                       } label: {
                                           Image(systemName: "bubble.left")
                                               .font(.subheadline)
                                       }
                                       .buttonStyle(.plain)
                                       .foregroundColor(.gray)
                                   }
                               }

                               // ✍🏻 Contenido de la reseña
                               Text(review.content)
                                   .font(.body)
                                   .foregroundColor(.primary)

                               HStack {
                                   Text(review.date.formatted(date: .abbreviated, time: .shortened))
                                       .font(.caption)
                                       .foregroundColor(.gray)

                                   Spacer()

                                   // 📚 Mostrar título del libro si existe
                                   if let bookTitle = review.bookTitle {
                                       Text("📚 \(bookTitle)")
                                           .font(.caption)
                                           .foregroundColor(.blue)
                                   }
                               }

                               
                           }
                           .padding(.vertical, 8)
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
                   // Aquí va  AddReviewView
                   // AddReviewView(onReviewAdded: { ... })
               }
               .sheet(isPresented: $showReplySheet) {
                   if let review = selectedReview {
                       ReplySheetView()
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
   

    func loadReviews() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(uid).collection("timeline")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let snapshot = snapshot {
                    let timelineReviews = snapshot.documents.compactMap { doc -> Review? in
                        let data = doc.data()
                        return Review(
                            id: data["reviewID"] as? String,
                            userID: data["userID"] as? String ?? "",
                            bookID: data["bookID"] as? String,
                            title: data["title"] as? String ?? "",
                            content: data["content"] as? String ?? "",
                            date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                            username: data["username"] as? String,
                            photoURL: data["photoURL"] as? String
                        )
                    }

                    self.reviews = timelineReviews
                }
            }
    }

    
}


#Preview {
    TimelineView()
        
}
