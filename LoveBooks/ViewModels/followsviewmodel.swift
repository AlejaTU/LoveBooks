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
    @MainActor
    func followUser(userIDToFollow: String) async {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let follow = FollowedItem(
            followerID: currentUserID,
            type: .user,
            followingUserID: userIDToFollow,
            followingBookID: nil,
            date: Date()
        )
        let db = Firestore.firestore()

        do {
            // Guardar el follow
                   _ = try db.collection("follows").addDocument(from: follow)

                   // ✅ Incrementar followers del usuario seguido
                   try await db.collection("users").document(userIDToFollow).updateData([
                       "followersCount": FieldValue.increment(Int64(1))
                   ])

                   // ✅ Incrementar following del usuario actual
                   try await db.collection("users").document(currentUserID).updateData([
                       "followingCount": FieldValue.increment(Int64(1))
                   ])

                   followedUsers.append(userIDToFollow)
            let reviewsSnapshot = try await db.collection("reviews")
                       .whereField("userID", isEqualTo: userIDToFollow)
                       .getDocuments()

                   for doc in reviewsSnapshot.documents {
                       var reviewData = doc.data()
                       reviewData["reviewID"] = doc.documentID

                       try await db.collection("users")
                           .document(currentUserID)
                           .collection("timeline")
                           .document(doc.documentID)
                           .setData(reviewData)
                   }

                   print(" Reseñas del seguido añadidas al timeline del seguidor")

        } catch {
            print("❌ Error al seguir usuario:", error.localizedDescription)
        }
    }

    //funcion para dejar de seguir
    @MainActor
    func unfollowUser(userIDToUnfollow: String) async {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        do {
            let snapshot = try await db.collection("follows")
                .whereField("followerID", isEqualTo: currentUserID)
                .whereField("followingUserID", isEqualTo: userIDToUnfollow)
                .whereField("type", isEqualTo: "user")
                .getDocuments()

            for doc in snapshot.documents {
                try await doc.reference.delete()
            }

            followedUsers.removeAll { $0 == userIDToUnfollow }

            //  Decrementar followingCount del actual y followersCount del otro
            async let decrementCurrentUser: () = decrementCounter(userID: currentUserID, field: "followingCount")
            async let decrementOtherUser: () = decrementCounter(userID: userIDToUnfollow, field: "followersCount")
            _ = try await [decrementCurrentUser, decrementOtherUser]

        } catch {
            print("❌ Error al dejar de seguir usuario:", error.localizedDescription)
        }
    }
    private func decrementCounter(userID: String, field: String) async throws {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)

        _ = try await db.runTransaction({ (transaction, errorPointer) -> Any? in
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(userRef)
            } catch let error {
                errorPointer?.pointee = error as NSError
                return nil
            }

            if let currentValue = snapshot.data()?[field] as? Int, currentValue > 0 {
                transaction.updateData([field: currentValue - 1], forDocument: userRef)
            }

            return nil
        })
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
