//
//  ReviewViewModel.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 21/5/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
@Observable
class ReviewViewModel  {

     var errorMessage: String = ""
     var isLoading: Bool = false
    
    private func saveBookIfNeeded(id: String, title: String) async {
        let cleanID = id.components(separatedBy: "/").last ?? id
        let db = Firestore.firestore()
        let docRef = db.collection("books").document(cleanID)

        do {
            let doc = try await docRef.getDocument()
            if !doc.exists {
                try await docRef.setData(["title": title])
                print("📚 Libro guardado en Firestore con ID limpio: \(cleanID)")
            }
        } catch {
            print("❌ Error al guardar libro:", error.localizedDescription)
        }
    }


    func publishReview(bookID: String?, bookTitle: String?, reviewTitle: String, content: String) async -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "Debes iniciar sesión primero."
            return false
        }

        isLoading = true
        var cleanBookID: String? = nil

        if let bookID, !bookID.isEmpty {
               cleanBookID = bookID.components(separatedBy: "/").last ?? bookID
               await saveBookIfNeeded(id: cleanBookID!, title: bookTitle ?? "Sin título")
           }

        let userSnapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument()
           let userData = userSnapshot?.data()
           let username = userData?["username"] as? String ?? "Usuario"
           let photoURL = userData?["photoURL"] as? String
        
           let review = Review(
               userID: uid,
               bookID: cleanBookID,
               title: reviewTitle,
               content: content,
               date: Date(),
               username: username,
                   photoURL: photoURL
           )
        
        
        do {
            // Guarda la reseña
            let docRef = Firestore.firestore().collection("reviews").document()
            let reviewID = docRef.documentID

            let reviewData: [String: Any] = [
                "reviewID": reviewID,
                "userID": uid,
                "bookID": cleanBookID as Any,
                "title": reviewTitle,
                "content": content,
                "date": Date(),
                "username": username,
                "photoURL": photoURL as Any
            ]


            try await docRef.setData(reviewData)


            // ✅ Incrementa el contador de reseñas del usuario
            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .updateData([
                    "reviewsCount": FieldValue.increment(Int64(1))
                ])
            try await addReviewToFollowersTimeline(review: Review(
                id: reviewID,
                userID: uid,
                bookID: cleanBookID,
                title: reviewTitle,
                content: content,
                date: Date(),
                username: username,
                    photoURL: photoURL
            ))

            isLoading = false
            return true


        } catch {
            errorMessage = "Error al guardar la reseña. Inténtalo de nuevo."
            print("❌ Error guardando reseña:", error.localizedDescription)

            isLoading = false
            return false
        }
    }
    private func addReviewToFollowersTimeline(review: Review) async throws {
        let db = Firestore.firestore()

        // 1. Obtener los seguidores del autor de la reseña
        let snapshot = try await db.collection("follows")
            .whereField("type", isEqualTo: "user")
            .whereField("followingUserID", isEqualTo: review.userID)
            .getDocuments()

        let followers: [String] = snapshot.documents.compactMap {
            try? $0.data(as: FollowedItem.self).followerID
        }
        let allUserIDs = followers + [review.userID]

        let userSnapshot = try await db.collection("users").document(review.userID).getDocument()
        let userData = userSnapshot.data()
        let username = userData?["username"] as? String ?? "Usuario"
        let photoURL = userData?["photoURL"] as? String

        // 2. Crear copia del review en cada timeline
        for userID in allUserIDs {
            let ref = db.collection("users").document(userID).collection("timeline").document()
            try await ref.setData([
                "reviewID": review.id ?? UUID().uuidString,
                "userID": review.userID,
                "title": review.title,
                "content": review.content,
                "date": review.date,
                "bookID": review.bookID as Any,
                "bookTitle": review.bookID != nil ? (try? await db.collection("books").document(review.bookID!).getDocument().data()?["title"] as? String ?? "") : nil,
                "username": username,
                            "photoURL": photoURL
            ])
        }
    }


}

