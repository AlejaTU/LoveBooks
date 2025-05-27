//
//  BookReviewsViewModel.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 22/5/25.
//

import Foundation
import FirebaseFirestore



@MainActor
@Observable
final class BookReviewsViewModel {
    var reviews: [Review] = []
    var isLoading: Bool = false
    var errorMessage: String = ""

    func fetchReviews(for bookID: String) async {
        //quitar el works del path de la api para guardar en firebase
        let cleanID = bookID.components(separatedBy: "/").last ?? bookID

        isLoading = true
        errorMessage = ""

        do {
            let snapshot = try await Firestore.firestore()
                .collection("reviews")
                .whereField("bookID", isEqualTo: cleanID)
                .order(by: "date", descending: true)
                .getDocuments()

            self.reviews = try snapshot.documents.compactMap {
                try $0.data(as: Review.self)
            }

            isLoading = false
        } catch {
            self.errorMessage = "Error al cargar reseñas del libro."
            print("❌ Error cargando reseñas:", error.localizedDescription)
            isLoading = false
        }
    }

}
