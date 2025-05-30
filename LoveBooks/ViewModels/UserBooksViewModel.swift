import Foundation
import FirebaseAuth
import FirebaseFirestore

import Observation

@Observable
@MainActor
class UserBooksViewModel {
    private let db = Firestore.firestore()
    
    // Añadir libro a favoritos
    func addToFavorites(book: Book) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let safeBookID = book.id.replacingOccurrences(of: "/", with: "_")

        let userBook = UserBook(
            id: safeBookID,
            userID: uid,
            book: book,
            status: "favorite",
            dateAdded: Date()
        )

        do {
            try db.collection("usersBook")
                .document(uid)
                .collection("favorites")
                .document(safeBookID)
                .setData(from: userBook)
        } catch {
            print("❌ Error al añadir a favoritos: \(error.localizedDescription)")
        }
    }
    
    // Eliminar libro de favoritos
    func removeFromFavorites(bookID: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let safeBookID = bookID.replacingOccurrences(of: "/", with: "_")

        do {
            try await db.collection("usersBook")
                .document(uid)
                .collection("favorites")
                .document(safeBookID)
                .delete()
        } catch {
            print("❌ Error al eliminar favorito: \(error.localizedDescription)")
        }
    }
    
    // Verificar si es favorito
    func isFavorite(bookID: String) async -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        let safeBookID = bookID.replacingOccurrences(of: "/", with: "_")

        do {
            let doc = try await db.collection("usersBook")
                .document(uid)
                .collection("favorites")
                .document(safeBookID)
                .getDocument()
            return doc.exists
        } catch {
            print("❌ Error al comprobar favorito: \(error.localizedDescription)")
            return false
        }
    }
}
