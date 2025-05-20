//
//  LoginView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 19/5/25.
//

import SwiftUI
import FirebaseAuth



struct LoginView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var goToSignUp = false
    @State private var errorMessage: String = ""
    
    //@Environment private var appState: AppState
    
    @Environment(AppState.self) var appState
    @State private var showSignUp = false


    
    private var isFormValid: Bool {
        !email.isEmptyOrWhiteSpace &&
                !password.isEmptyOrWhiteSpace 
        
    }
    
    
    private func login() async {
        do {
           let _ = try await   Auth.auth().signIn(withEmail: email, password: password)

            
            //ir a la pantalla principal
            appState.authStatus = .loggedIn
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    var body: some View {
        NavigationStack {
                ZStack {
                    Color("#FAF8F4").ignoresSafeArea()

                    VStack(spacing: 30) {
                        Spacer()

                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180)
                            .cornerRadius(30)
                            .padding(.bottom, 20)
                            

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

                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal)

                        Button(action: {
                            Task { await login() }
                        }) {
                            Text("Iniciar sesión")
                                .foregroundStyle(Color.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("#7A6E5F"))
                                .cornerRadius(12)
                                .font(.title.bold())
                                .shadow( radius: 6, x: 0, y: 4)
                        }
                        .padding(.horizontal)
                        .disabled(!isFormValid)
                        .opacity(isFormValid ? 1 : 0.3)

                        
                                Button(action: {

                                    showSignUp = true
                            }) {
                                Text("¿Aún no tienes cuenta?")
                                    .foregroundStyle(Color.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .font(.subheadline)
                                    .background(Color("#7A6E5F"))
                                    .cornerRadius(12)
                                    .font(.title2.bold())
                                    .shadow( radius: 3, x: 0, y: 2)
                            }
                        



                        Spacer()
                    }
                    .padding()
                    .navigationDestination(isPresented: $showSignUp) {
                        SignUpView(model: Model())
                    }
                }
            }
        }
    }

#Preview {
    LoginView()
        .environment(AppState())
}
