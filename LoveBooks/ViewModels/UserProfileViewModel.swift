//
//  UserProfileViewModel.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 23/5/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

@MainActor
@Observable
class UserProfileViewModel {
    var profile: UserProfile?
    var userReviews: [Review] = []
    var bookTitles: [String: String] = [:] // bookID: bookTitle


    // Crear perfil al registrarse
    func createProfile(username: String, bio: String = "", photoURL: String? = nil) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "No user logged in", code: 401)
        }

        let profile = UserProfile(
            id: user.uid,
            username: username,
            email: user.email ?? "",
            bio: bio,
            photoURL: photoURL,
            followersCount: 0,
            followingCount: 0,
            reviewsCount: 0
        )

        try Firestore.firestore()
            .collection("users")
            .document(user.uid)
            .setData(from: profile)
    }

    // Cargar perfil para mostrar en la vista
    func fetchProfile() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            let snapshot = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()

            let profile = try snapshot.data(as: UserProfile.self) 
                self.profile = profile
            
        } catch {
            print("❌ Error al obtener el perfil:", error.localizedDescription)
        }
    }
    
    
    func updateProfile(username: String, bio: String, imageData: Data?) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "No user", code: 401)
        }

        var photoURL: String? = nil

        if let imageData {
            let ref = Storage.storage().reference().child("profile_photos/\(uid).jpg")
            _ = try await ref.putDataAsync(imageData)
            photoURL = try await ref.downloadURL().absoluteString
        }

        var data: [String: Any] = [
            "username": username,
            "bio": bio
        ]

        
        if let url = photoURL {
            data["photoURL"] = url
        } else {
            data["photoURL"] = FieldValue.delete()
        }

        try await Firestore.firestore()
            .collection("users")
            .document(uid)
            .updateData(data)

        await fetchProfile()
    }
    
    func isUsernameAvailable(_ username: String) async -> Bool {
        let db = Firestore.firestore()
        do {
            let snapshot = try await db.collection("users")
                .whereField("username", isEqualTo: username)
                .getDocuments()
            
            // Si no hay ningún documento, el username está disponible
            return snapshot.documents.isEmpty
        } catch {
            print("❌ Error al verificar nombre de usuario:", error.localizedDescription)
            return false
        }
    }



    func fetchUserReviews() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            let snapshot = try await Firestore.firestore()
                .collection("reviews")
                .whereField("userID", isEqualTo: uid)
                .order(by: "date", descending: true)
                .getDocuments()

            self.userReviews = try snapshot.documents.compactMap {
                try $0.data(as: Review.self)
            }

            // 🔍 Obtener títulos de los libros
            for review in userReviews {
                if let bookID = review.bookID, bookTitles[bookID] == nil {
                    let bookDoc = try await Firestore.firestore()
                        .collection("books")
                        .document(bookID)
                        .getDocument()

                    if let title = bookDoc.data()?["title"] as? String {
                        bookTitles[bookID] = title
                    }
                }
            }

        } catch {
            print("❌ Error al obtener reseñas del usuario:", error.localizedDescription)
        }
    }

    func fetchProfile(for userID: String? = nil) async {
        let uid = userID ?? Auth.auth().currentUser?.uid
        guard let uid else { return }

        do {
            let snapshot = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()

            self.profile = try snapshot.data(as: UserProfile.self)
        } catch {
            print("❌ Error al obtener el perfil:", error.localizedDescription)
        }
    }

    
}
