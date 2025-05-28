//
//  CreateCommunityView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 28/5/25.
//

import SwiftUI
import FirebaseAuth

struct CreateCommunityView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var viewModel: CommunityViewModel
    
    @State private var name = ""
    @State private var description = ""
    let userID = Auth.auth().currentUser?.uid


    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Nombre")) {
                    TextField("Ej. Club de lectura de ciencia ficción", text: $name)
                }
                Section(header: Text("Descripción")) {
                    TextField("¿De qué trata tu comunidad?", text: $description)
                }
            }
            .navigationTitle("Nueva comunidad")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") {
                        Task {
                            if let userID = Auth.auth().currentUser?.uid {
                                let newCommunity = Community(
                                    id: nil,
                                    name: name,
                                    description: description,
                                    ownerID: userID,
                                    createdAt: Date(),
                                    bookOfTheMonthID: nil,
                                    participants: []
                                )
                                await viewModel.createCommunity(newCommunity)
                                await viewModel.fetchCommunities()
                                dismiss()
                            } else {
                                print("❌ Usuario no autenticado.")
                            }


                      
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || description.isEmpty)
                }
            }
        }
    }
}



 
