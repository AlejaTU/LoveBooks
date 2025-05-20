//
//  followsviewmodel.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 20/5/25.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
@Observable
class FollowsViewModel {
    var followedUsers: [String] = []
    var followedBooks: [String] = []

    func fetchFollowedItems() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()

        do {
            let snapshot = try await db.collection("follows")
                .whereField("followerID", isEqualTo: uid)
                .getDocuments()

            let items: [FollowedItem] = try snapshot.documents.compactMap { doc in
                let data = doc.data()
                guard
                    let followerID = data["followerID"] as? String,
                    let typeString = data["type"] as? String,
                    let type = FollowType(rawValue: typeString),
                    let targetID = data["targetID"] as? String,
                    let timestamp = data["date"] as? Timestamp
                else { return nil }

                return FollowedItem(
                    id: doc.documentID,
                    followerID: followerID,
                    type: type,
                    targetID: targetID,
                    date: timestamp.dateValue()
                )
            }

            // Guardamos los IDs separados por tipo
            self.followedUsers = items.filter { $0.type == .user }.map { $0.targetID }
            self.followedBooks = items.filter { $0.type == .book }.map { $0.targetID }

        } catch {
            print("❌ Error al obtener follows:", error.localizedDescription)
        }
    }
}
