//
//  EditProfileView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 25/5/25.
//

import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var username: String
    @State private var bio: String
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImageData: Data?
    
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert = false
    
    @Environment(UserProfileViewModel.self) var userProfileVM
    
    
    
    
    init(currentUsername: String, currentBio: String) {
        _username = State(initialValue: currentUsername)
        _bio = State(initialValue: currentBio)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Foto de perfil
                    if let imageData = profileImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    }
                    
                    PhotosPicker("Seleccionar foto", selection: $selectedPhoto, matching: .images)
                        .onChange(of: selectedPhoto) {
                            Task {
                                if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                                    profileImageData = data
                                }
                            }
                        }
                    
                    // Campo de nombre
                    TextField("Nombre de usuario", text: $username)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                    
                    // Campo de biografía
                    TextEditor(text: $bio)
                        .frame(height: 100)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                    
                    // Botón guardar
                    Button("Guardar cambios") {
                        Task {
                            await saveChanges()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(isSaving)
                    
                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding()
            }
            .navigationTitle("Editar perfil")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }.alert("Perfil actualizado", isPresented: $showSuccessAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("Los cambios se guardaron correctamente.")
        }
    }
    
    // Función para guardar los cambios
    func saveChanges() async {
        isSaving = true
        errorMessage = nil
        
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No hay usuario autenticado"
            isSaving = false
            return
        }
        
        var photoURL: String? = nil
        
       
        if let imageData = profileImageData {
            let ref = Storage.storage().reference().child("profile_photos/\(uid).jpg")
            do {
                _ = try await ref.putDataAsync(imageData)
                photoURL = try await ref.downloadURL().absoluteString
            } catch {
                errorMessage = "Error al subir imagen"
                isSaving = false
                return
            }
        }
        
        let data: [String: Any] = [
            "username": username,
            "bio": bio,
            "photoURL": photoURL ?? FieldValue.delete()
        ]
        
        do {
            try await Firestore.firestore().collection("users").document(uid).updateData(data)
            showSuccessAlert = true
        } catch {
            errorMessage = "Error al guardar los cambios"
        }
        
        isSaving = false
    }
}

/*
#Preview {
    EditProfileView()
}
*/
