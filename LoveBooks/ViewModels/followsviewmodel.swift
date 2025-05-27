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
    
    
    //funcion para seguir user
    func followUser(userIDToFollow: String) async {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let follow = FollowedItem(
            followerID: currentUserID,
            type: .user,
            followingUserID: userIDToFollow,
            followingBookID: nil,
            date: Date()
        )

        do {
            _ = try Firestore.firestore()
                .collection("follows")
                .addDocument(from: follow)

            followedUsers.append(userIDToFollow)

        } catch {
            print("❌ Error al seguir usuario:", error.localizedDescription)
        }
    }

    //funcion para dejar de seguir
    func unfollowUser(userIDToUnfollow: String) async {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        do {
            let snapshot = try await Firestore.firestore()
                .collection("follows")
                .whereField("followerID", isEqualTo: currentUserID)
                .whereField("followingUserID", isEqualTo: userIDToUnfollow)
                .whereField("type", isEqualTo: "user")
                .getDocuments()

            for doc in snapshot.documents {
                try await doc.reference.delete()
            }

            followedUsers.removeAll { $0 == userIDToUnfollow }

        } catch {
            print("❌ Error al dejar de seguir usuario:", error.localizedDescription)
        }
    }

    func isFollowing(userID: String) -> Bool {
        followedUsers.contains(userID)
    }


    func fetchFollowedItems() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()

        do {
            let snapshot = try await db.collection("follows")
                .whereField("followerID", isEqualTo: uid)
                .getDocuments()

            let items: [FollowedItem] = try snapshot.documents.compactMap {
                try $0.data(as: FollowedItem.self)
            }

            // ✅ Ahora separamos por campos correctos
            self.followedUsers = items
                .filter { $0.type == .user }
                .compactMap { $0.followingUserID }

            self.followedBooks = items
                .filter { $0.type == .book }
                .compactMap { $0.followingBookID }

        } catch {
            print("❌ Error al obtener follows:", error.localizedDescription)
        }
    }

}
