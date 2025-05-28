//
//  MonthlyBookViewModel.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 28/5/25.
//

import Foundation
import FirebaseFirestore


@MainActor
@Observable
class MonthlyBookViewModel {
    var currentMonthlyBook: Book?
    var isLoading = false
    var errorMessage: String?

    func fetchCurrentBook(for communityID: String) async {
        isLoading = true
        errorMessage = nil
        let monthID = getCurrentMonthID()

        do {
            let snapshot = try await Firestore.firestore()
                .collection("communities")
                .document(communityID)
                .collection("monthlyBooks")
                .document(monthID)
                .getDocument()

            currentMonthlyBook = try snapshot.data(as: Book.self)

        } catch {
            currentMonthlyBook = nil
            errorMessage = "No se pudo cargar el libro del mes."
            print("❌ Error:", error.localizedDescription)
        }

        isLoading = false
    }


    func addMonthlyBook(for communityID: String, book: Book) async {
        do {
            let monthID = getCurrentMonthID()
            try Firestore.firestore()
                .collection("communities")
                .document(communityID)
                .collection("monthlyBooks")
                .document(monthID)
                .setData(from: book)
        } catch {
            print("❌ Error al añadir libro del mes:", error.localizedDescription)
        }
    }

    private func getCurrentMonthID() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }
}
