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

    func publishReview(bookID: String, title: String, content: String) async -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "Debes iniciar sesión primero."
            return false
        }

        isLoading = true

        let review = Review(
            userID: uid,
            bookID: bookID,
            title: title,
            content: content,
            date: Date()
        )

        do {
            let _ = try Firestore.firestore()
                .collection("reviews")
                .addDocument(from: review)
            
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

