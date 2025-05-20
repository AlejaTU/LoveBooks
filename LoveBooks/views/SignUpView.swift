//
//  SignUpView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 19/5/25.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var displayName: String = ""
    @State private var errorMessage: String = ""
    @State private var showPasswordError: Bool = false
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var showSuccess = false

    @Bindable  var model: Model
    
    private var isPasswordValid: Bool {
          password.count >= 8 &&
          password.hasUppercase &&
          password.hasNumber &&
          password.hasSpecialCharacter
      }
    
    private var isFormValid: Bool {
        !email.isEmptyOrWhiteSpace &&
                !password.isEmptyOrWhiteSpace &&
                !confirmPassword.isEmptyOrWhiteSpace &&
                !displayName.isEmptyOrWhiteSpace &&
                password == confirmPassword &&
                isPasswordValid
        
    }
    

    
    private func signUp() async {
        showPasswordError = true
        guard password == confirmPassword else {
                   errorMessage = "Las contraseñas no coinciden."
                   return
               }
        guard isPasswordValid else {
                   errorMessage = "La contraseña debe tener al menos 8 caracteres, una mayúscula, un número y un símbolo."
                   return
               }
        do {
            let result = try await   Auth.auth().createUser(withEmail: email, password: password)
            try await model.updateDisplayName(for: result.user, displayName: displayName)
            appState.authStatus = .loggedOut
            // ✅ Limpiamos campos
                   email = ""
                   password = ""
                   confirmPassword = ""
                   displayName = ""
                   errorMessage = ""
                   showPasswordError = false

                   // ✅ Mostramos alerta de éxito
                   showSuccess = true

        } catch {
            errorMessage = error.localizedDescription
        }
        
    }
    
    
    var body: some View {
        
                    ZStack {
                        Color("#FAF8F4").ignoresSafeArea()

                        VStack(spacing: 30) {
                            Spacer()

                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 160)
                                .cornerRadius(20)
                                .padding(.bottom, 10)

                            VStack(spacing: 16) {
                                TextField("Email", text: $email)
                                    .textInputAutocapitalization(.never)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 1)

                                SecureField("Contraseña", text: $password)
                                    .textInputAutocapitalization(.never)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 1)
                                    .onChange(of: password) { _ in
                                        showPasswordError = true
                                    }

                                SecureField("Repetir contraseña", text: $confirmPassword)
                                    .textInputAutocapitalization(.never)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 1)

                                if showPasswordError && !password.isEmpty && !isPasswordValid {
                                    Text("Debe tener al menos 8 caracteres, una mayúscula, un número y un símbolo.")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                        .padding(.top, 2)
                                }

                                TextField("Nombre de usuario", text: $displayName)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 1)

                                if !errorMessage.isEmpty {
                                    Text(errorMessage)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal)

                            Button(action: {
                                Task { await signUp() }
                            }) {
                                Text("Crear cuenta")
                                    .foregroundStyle(Color.black)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(isFormValid ? Color.blue : Color("##9F9280"))
                                    
                                    .cornerRadius(12)
                                    .font(.headline)
                                    .shadow(radius: 4, x: 0, y: 2)
                                    .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.black.opacity(0.3), lineWidth: 2)
                                            )
                            }
                            .padding(.horizontal)
                            .disabled(!isFormValid)
                            .opacity(isFormValid ? 1 : 0.3)

                            Button(action: {
                                dismiss()
                            }) {
                                Text("¿Ya tienes cuenta? Inicia sesión")
                                    .foregroundStyle(Color.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("#9F9280"))
                                    .cornerRadius(12)
                                    .font(.headline)
                                    .shadow(radius: 4, x: 0, y: 2)
                            }
                            .padding(.horizontal)

                            Spacer()
                        }
                        .padding()
                        .alert("Registro exitoso", isPresented: $showSuccess) {
                            Button("Iniciar sesión") {
                                dismiss()
                            }
                        } message: {
                            Text("Tu cuenta ha sido creada correctamente.")
                        }
                       
                    }
                }
            }
        

#Preview {
    SignUpView(model: Model())
}
