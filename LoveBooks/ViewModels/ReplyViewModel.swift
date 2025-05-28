//
//  ReplyViewModel.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 28/5/25.
//

// ReplyViewModel.swift
// LoveBooks

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
@Observable
class ReplyViewModel {
    
    var errorMessage: String = ""
    
    func publishReply(to parentReviewID: String, content: String) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "Debes iniciar sesión primero."
            return
        }

        let db = Firestore.firestore()
        let replyID = UUID().uuidString
        let date = Date()
        
        // Obtener datos del usuario
        let userSnapshot = try? await db.collection("users").document(uid).getDocument()
        let userData = userSnapshot?.data()
        let username = userData?["username"] as? String ?? "Usuario"
        let photoURL = userData?["photoURL"] as? String

        // Crear la respuesta
        let replyData: [String: Any] = [
            "id": replyID,
            "parentID": parentReviewID,
            "userID": uid,
            "content": content,
            "date": date,
            "username": username,
            "photoURL": photoURL as Any
        ]

        do {
            try await db.collection("replies").document(replyID).setData(replyData)
            print("💬 Respuesta publicada")
        } catch {
            print("❌ Error publicando respuesta: \(error.localizedDescription)")
            errorMessage = "No se pudo publicar la respuesta."
        }
    }
}
