//
//  Untitled.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 28/5/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
@Observable
class CommunityViewModel {
    var communities: [Community] = []
    var isLoading = false
    var errorMessage: String?
    
    var currentUserID: String {
        Auth.auth().currentUser?.uid ?? ""
    }


    func fetchCommunities() async {
        isLoading = true
        errorMessage = nil

       
        
        do {
            let snapshot = try await Firestore.firestore()
                .collection("communities")
                .order(by: "createdAt", descending: true)
                .getDocuments()

            communities = try snapshot.documents.compactMap {
                try $0.data(as: Community.self)
            }
        } catch {
            errorMessage = "No se pudieron cargar las comunidades."
            print("❌ Error al cargar comunidades:", error.localizedDescription)
        }

        isLoading = false
    }

    func createCommunity(_ community: Community) async {
        do {
            var newCommunity = community
            newCommunity.createdAt = Date()
            newCommunity.ownerID = currentUserID

            _ = try Firestore.firestore()
                .collection("communities")
                .addDocument(from: newCommunity)
        } catch {
            print("❌ Error al crear la comunidad:", error.localizedDescription)
        }
    }
    
    
    func deleteCommunity(_ community: Community) async {
            guard let communityID = community.id else {
                print("❌ Comunidad sin ID. No se puede eliminar.")
                return
            }

            do {
                try await Firestore.firestore()
                    .collection("communities")
                    .document(communityID)
                    .delete()

                // Opcional: actualiza localmente
                communities.removeAll { $0.id == communityID }

            } catch {
                print("❌ Error al eliminar la comunidad:", error.localizedDescription)
            }
        }
    
}
