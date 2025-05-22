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
        isLoading = true
        errorMessage = ""

        do {
            let snapshot = try await Firestore.firestore()
                .collection("reviews")
                .whereField("bookID", isEqualTo: bookID)
                .order(by: "date", descending: true)
                .getDocuments()

            reviews = snapshot.documents.compactMap { doc in
                try? doc.data(as: Review.self)
            }

        } catch {
            errorMessage = "Error cargando reseñas."
            print("❌ Error fetching reviews:", error.localizedDescription)
        }

        isLoading = false
    }
}
