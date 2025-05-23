//
//  ProfileView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 20/5/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
           NavigationStack {
               ScrollView {
                   VStack(spacing: 24) {
                       
                       // 📊 Contadores
                       HStack(spacing: 40) {
                           VStack {
                               Text("24").bold()
                               Text("Seguidores").font(.caption)
                           }
                           VStack {
                               Text("17").bold()
                               Text("Siguiendo").font(.caption)
                           }
                           VStack {
                               Text("12").bold()
                               Text("Reseñas").font(.caption)
                           }
                       }
                       .padding(.top)

                       Divider()

                       // 📚 Lista de reseñas (placeholder)
                       VStack(alignment: .leading, spacing: 16) {
                           Text("Mis reseñas")
                               .font(.headline)

                           ForEach(0..<3, id: \.self) { _ in
                               VStack(alignment: .leading, spacing: 8) {
                                   Text("Título de ejemplo")
                                       .font(.headline)
                                   Text("Contenido de reseña... muy interesante...")
                                       .font(.body)
                                       .lineLimit(2)
                                   Text("Fecha")
                                       .font(.caption)
                                       .foregroundColor(.gray)
                               }
                               .padding()
                               .background(Color.white)
                               .cornerRadius(8)
                               .shadow(radius: 1)
                           }
                       }
                       .padding(.horizontal)
                   }
                   .padding()
               }
               .navigationTitle("Mi perfil")
               .toolbar {
                   Button("Cerrar sesión") {
                       // acción de logout
                   }
               }
               .background(Color("#FAF8F4").ignoresSafeArea())
           }
       }
   }
#Preview {
    ProfileView()
}
