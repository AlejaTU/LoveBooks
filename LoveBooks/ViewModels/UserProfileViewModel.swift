//
//  UserProfileViewModel.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 23/5/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
@Observable
class UserProfileViewModel {
    var profile: UserProfile?

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
}
