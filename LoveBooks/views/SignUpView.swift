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
        } catch {
            errorMessage = error.localizedDescription
        }
        
    }
    
    
    var body: some View {
        Form {
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $password)
                .textInputAutocapitalization(.never)
                .onChange(of: password) { _ in
                    showPasswordError = true
                }
            SecureField("Repetir contraseña", text: $confirmPassword)
                       .textInputAutocapitalization(.never)
            if showPasswordError && !password.isEmpty && !isPasswordValid {
                Text("La contraseña debe tener al menos 8 caracteres, una mayúscula, un número y un símbolo.")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 2)
            }
            TextField("Display Name", text: $displayName)
            
            if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
            HStack {
                Spacer()
                Button("Sign up") {
                    Task {
                        await signUp()
                        
                    }
                }.disabled(!isFormValid)
                    .buttonStyle(.borderless)
                
                
                Button("Login") {
                    //usuario va a login
                }.buttonStyle(.borderless)
                Spacer()
            }
            
            
        }

    }
}

#Preview {
    SignUpView(model: Model())
}
