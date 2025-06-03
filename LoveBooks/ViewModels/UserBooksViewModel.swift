import Foundation
import FirebaseAuth
import FirebaseFirestore

import Observation

@Observable
@MainActor
class UserBooksViewModel {
    private let db = Firestore.firestore()
    var favoriteBooks: [Book] = []
    var pendingBooks: [Book] = []
        var readBooks: [Book] = []
    
    
    
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
    
    
    
    // Obtener lista de libros favoritos
    func fetchFavorites() async {
           guard let uid = Auth.auth().currentUser?.uid else { return }

           do {
               let snapshot = try await db.collection("usersBook")
                   .document(uid)
                   .collection("favorites")
                   .getDocuments()

               let favorites: [UserBook] = snapshot.documents.compactMap { doc in
                   try? doc.data(as: UserBook.self)
               }

               self.favoriteBooks = favorites.map { $0.book }
           } catch {
               print("❌ Error al obtener favoritos: \(error.localizedDescription)")
               self.favoriteBooks = []
           }
       }
   
    
    func addToReadingList(book: Book, status: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let safeBookID = book.id.replacingOccurrences(of: "/", with: "_")

        let userBook = UserBook(
            id: safeBookID,
            userID: uid,
            book: book,
            status: status,
            dateAdded: Date()
        )

        do {
            try db.collection("usersBook")
                .document(uid)
                .collection("status")
                .document(safeBookID)
                .setData(from: userBook)
            if status == "read" {
                      let year = Calendar.current.component(.year, from: Date())
                      await incrementBooksReadInYear(year)
                  }
        } catch {
            print("❌ Error al añadir a \(status): \(error.localizedDescription)")
        }
    }

    func fetchReadingList(for status: String) async {
           guard let uid = Auth.auth().currentUser?.uid else { return }

           do {
               let snapshot = try await db.collection("usersBook")
                   .document(uid)
                   .collection("status")
                   .whereField("status", isEqualTo: status)
                   .getDocuments()

               let userBooks = snapshot.documents.compactMap { try? $0.data(as: UserBook.self) }

               if status == "pending" {
                   self.pendingBooks = userBooks.map { $0.book }
               } else if status == "read" {
                   self.readBooks = userBooks.map { $0.book }
               }
           } catch {
               print("❌ Error al obtener \(status): \(error.localizedDescription)")
               if status == "pending" {
                   self.pendingBooks = []
               } else if status == "read" {
                   self.readBooks = []
               }
           }
       }
    
    
     func fetchBooksByStatus(_ status: String) async -> [UserBook] {
         guard let uid = Auth.auth().currentUser?.uid else { return [] }

         do {
             let snapshot = try await db.collection("usersBook")
                 .document(uid)
                 .collection("status")
                 .whereField("status", isEqualTo: status)
                 .getDocuments()

             return snapshot.documents.compactMap {
                 try? $0.data(as: UserBook.self)
             }
         } catch {
             print("❌ Error al obtener libros con status \(status):", error.localizedDescription)
             return []
         }
     }

     func updateBookStatus(bookID: String, newStatus: String) async {
         guard let uid = Auth.auth().currentUser?.uid else { return }

         do {
             try await db.collection("usersBook")
                 .document(uid)
                 .collection("status")
                 .document(bookID)
                 .updateData(["status": newStatus])
             if newStatus == "read" {
                       let year = Calendar.current.component(.year, from: Date())
                       await incrementBooksReadInYear(year)
                   }
         } catch {
             print("❌ Error al actualizar status:", error.localizedDescription)
         }
     }
    
    
    func countFavorites() async -> Int {
        guard let uid = Auth.auth().currentUser?.uid else { return 0 }

        do {
            let snapshot = try await db.collection("usersBook")
                .document(uid)
                .collection("favorites")
                .getDocuments()
            return snapshot.count
        } catch {
            print("❌ Error al contar favoritos: \(error.localizedDescription)")
            return 0
        }
    }

    func countBooksWithStatus(_ status: String) async -> Int {
        guard let uid = Auth.auth().currentUser?.uid else { return 0 }

        do {
            let snapshot = try await db.collection("usersBook")
                .document(uid)
                .collection("status")
                .whereField("status", isEqualTo: status)
                .getDocuments()
            return snapshot.count
        } catch {
            print("❌ Error al contar libros con status '\(status)': \(error.localizedDescription)")
            return 0
        }
    }

    
    func saveMonthlyGoal(_ goal: MonthlyGoal) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            try db.collection("usersBook")
                .document(uid)
                .collection("monthlyGoals")
                .document(goal.id ?? UUID().uuidString)
                .setData(from: goal)
        } catch {
            print("❌ Error al guardar la meta mensual: \(error.localizedDescription)")
        }
    }
    
    func getMonthlyGoal(for monthYear: String) async -> MonthlyGoal? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }

        do {
            let doc = try await db.collection("usersBook")
                .document(uid)
                .collection("monthlyGoals")
                .document(monthYear)
                .getDocument()

            return try doc.data(as: MonthlyGoal.self)
        } catch {
            print("❌ Error al obtener la meta mensual: \(error.localizedDescription)")
            return nil
        }
    }

    func incrementBooksReadInYear(_ year: Int) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let docRef = db.collection("usersBook")
            .document(uid)
            .collection("yearlyStats")
            .document("\(year)")

        do {
            let snapshot = try await docRef.getDocument()

            if snapshot.exists {
                try await docRef.updateData(["booksRead": FieldValue.increment(Int64(1))])
            } else {
                let stats = YearlyStats(booksRead: 1)
                try docRef.setData(from: stats)
            }
        } catch {
            print("❌ Error al actualizar estadísticas anuales: \(error.localizedDescription)")
        }
    }
    
    func getYearlyStats(for year: Int) async -> YearlyStats? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }

        do {
            let doc = try await db.collection("usersBook")
                .document(uid)
                .collection("yearlyStats")
                .document("\(year)")
                .getDocument()

            guard doc.exists else {
                print("📭 No existe el documento de estadísticas del año \(year)")
                return nil
            }

            return try doc.data(as: YearlyStats.self)
        } catch {
            print("❌ Error al obtener estadísticas anuales: \(error.localizedDescription)")
            return nil
        }
    }




    
   }
