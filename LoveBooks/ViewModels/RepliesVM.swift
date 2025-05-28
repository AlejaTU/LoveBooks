//
//  RepliesVM.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 28/5/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@Observable
class RepliesVM {
    var repliesByReview: [String: [Reply]] = [:]

    func loadReplies(for reviewID: String) async {
        // Evita recargar si ya están cargadas
        if repliesByReview[reviewID] != nil {
            return
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
                    id: doc.documentID,
                    parentID: data["parentID"] as? String ?? "",
                    userID: data["userID"] as? String ?? "",
                    content: data["content"] as? String ?? "",
                    date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                    username: data["username"] as? String ?? "Usuario",
                    photoURL: data["photoURL"] as? String
                )
            }

            repliesByReview[reviewID] = replies
        } catch {
            print("❌ Error cargando respuestas: \(error.localizedDescription)")
        }
    }
}
