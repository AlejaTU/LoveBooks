//
//  MonthlyBookViewModel.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 28/5/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
@Observable
class MonthlyBookViewModel {
    var currentMonthlyBook: Book?
    var isLoading = false
    var errorMessage: String?
    var justMovedToPast = false
     var members: [UserProfile] = []


    func fetchCurrentBook(for communityID: String) async {
        isLoading = true
        errorMessage = nil
        let currentMonthID = getCurrentMonthID()
        

        do {
            let ref = Firestore.firestore()
                .collection("communities")
                .document(communityID)
                .collection("monthlyBooks")
                .document(currentMonthID)

            let snapshot = try await ref.getDocument()

            if snapshot.exists {
                // ✅ Ya hay libro para este mes
                currentMonthlyBook = try snapshot.data(as: Book.self)
            } else {
                // ❌ No hay libro para este mes, buscar el anterior para moverlo a "pastBooks"
                let lastMonthID = getLastMonthID()
                let lastSnapshot = try await Firestore.firestore()
                    .collection("communities")
                    .document(communityID)
                    .collection("monthlyBooks")
                    .document(lastMonthID)
                    .getDocument()

                if snapshot.exists {
                    currentMonthlyBook = try snapshot.data(as: Book.self)
                } else {
                    // 🟡 Nuevo mes, no hay libro actual
                    await moveLastMonthBookToPast(for: communityID)
                    currentMonthlyBook = nil
                }


                // 🟡 Marcar como sin libro actual
                currentMonthlyBook = nil
            }

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
    
    private func getLastMonthID() -> String {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "es_ES")
        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: Date()) else {
            return getCurrentMonthID()
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: previousMonth)
    }
    
    
    var pastMonthlyBooks: [MonthlyBook] = []

    func fetchPastBooks(for communityID: String) async {
        let currentMonthID = getCurrentMonthID()

        do {
            let snapshot = try await Firestore.firestore()
                .collection("communities")
                .document(communityID)
                .collection("monthlyBooks")
                .getDocuments()

            let allBooks = try snapshot.documents.compactMap {
                try $0.data(as: MonthlyBook.self)
            }

            pastMonthlyBooks = allBooks.filter { $0.id != currentMonthID }

        } catch {
            print("❌ Error cargando libros anteriores:", error.localizedDescription)
            pastMonthlyBooks = []
        }
    }

    func moveLastMonthBookToPast(for communityID: String) async {
        let lastMonthID = getLastMonthID()

        do {
            let lastRef = Firestore.firestore()
                .collection("communities")
                .document(communityID)
                .collection("monthlyBooks")
                .document(lastMonthID)

            let lastSnapshot = try await lastRef.getDocument()

            if lastSnapshot.exists {
                let lastBook = try lastSnapshot.data(as: MonthlyBook.self)

                // Revisar si ya está en pastBooks
                let pastRef = Firestore.firestore()
                    .collection("communities")
                    .document(communityID)
                    .collection("pastBooks")
                    .document(lastMonthID)

                let pastSnapshot = try await pastRef.getDocument()
                justMovedToPast = true


                if !pastSnapshot.exists {
                    // Guardar en pastBooks
                    try  pastRef.setData(from: lastBook)
                }
            }
        } catch {
            print("❌ Error al mover libro a pasados:", error.localizedDescription)
        }
    }

    
    func isUserInCommunity(_ community: Community) -> Bool {
        guard let userID = Auth.auth().currentUser?.uid else { return false }
        return community.participants.contains(userID)
    }


    
    func fetchParticipants(for community: Community) async {
         guard let communityId = community.id else {
             members = []
             return
         }
         let db = Firestore.firestore()
         
         do {
             // 1) Leer el documento completo de la comunidad
             let communityDoc = try await db
                 .collection("communities")
                 .document(communityId)
                 .getDocument()
             
             let data = communityDoc.data() ?? [:]
             // 2) Extraer el array “participants” (listado de UIDs)
             let uids = data["participants"] as? [String] ?? []
             
             // 3) Si no hay UIDs, vaciamos members y salimos
             guard !uids.isEmpty else {
                 members = []
                 return
             }
             
             // 4) Para cada UID, buscamos “users/<uid>” y convertimos a UserProfile
             members = try await withThrowingTaskGroup(of: UserProfile.self) { group in
                 for uid in uids {
                     group.addTask {
                         let userDoc = try await db.collection("users").document(uid).getDocument()
                         return try userDoc.data(as: UserProfile.self)
                     }
                 }
                 return try await group.reduce(into: []) { $0.append($1) }
             }
         } catch {
             print("❌ Error al obtener los miembros:", error.localizedDescription)
             members = []
         }
     }

    @MainActor
       func toggleMembership(for community: Community) async {
           guard let communityId = community.id,
                 let userID = Auth.auth().currentUser?.uid else { return }
           
           if userID == community.ownerID {
               print("⚠️ El creador no puede abandonar su propio club.")
               return
           }
           
           let ref = Firestore.firestore().collection("communities").document(communityId)
           
           do {
               // Leer el array actual desde Firestore
               let snapshot = try await ref.getDocument()
               let data = snapshot.data() ?? [:]
               var participants = data["participants"] as? [String] ?? []
               
               if participants.contains(userID) {
                   // Si ya estaba, lo removemos
                   participants.removeAll { $0 == userID }
               } else {
                   // Si no estaba, lo agregamos
                   participants.append(userID)
               }
               
               // Actualizar Firestore con el nuevo array
               try await ref.updateData(["participants": participants])
           } catch {
               print("❌ Error al actualizar la participación:", error.localizedDescription)
           }
       }



}
