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

           let review = Review(
               userID: uid,
               bookID: cleanBookID,
               title: reviewTitle,
               content: content,
               date: Date()
           )
        
        
        do {
            // Guarda la reseña
            let _ = try Firestore.firestore()
                .collection("reviews")
                .addDocument(from: review)

            // ✅ Incrementa el contador de reseñas del usuario
            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .updateData([
                    "reviewsCount": FieldValue.increment(Int64(1))
                ])

            isLoading = false
            return true


        } catch {
            errorMessage = "Error al guardar la reseña. Inténtalo de nuevo."
            print("❌ Error guardando reseña:", error.localizedDescription)

            isLoading = false
            return false
        }
    }

}

