//
//  BookOfTheMonthView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 28/5/25.
//

import SwiftUI

struct BookOfTheMonthView: View {
    var community: Community

    var body: some View {
        VStack(spacing: 24) {
            // Imagen de portada (placeholder de momento)
            Image(systemName: "book.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .foregroundColor(.accentColor)
                .padding(.top)

            VStack(spacing: 8) {
                Text("Título del libro del mes")
                    .font(.title2)
                    .bold()
                Text("Autor del libro")
                    .foregroundColor(.secondary)
            }

            Text("Una breve sinopsis del libro para enganchar a los lectores. Puede ser un resumen de 2-3 líneas.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Botones
            VStack(spacing: 12) {
                Button(action: {
                    // Acción: unirse o salir
                }) {
                    Text("Unirme a la comunidad")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button(action: {
                    // Acción: mostrar libros anteriores
                }) {
                    Text("Ver libros anteriores")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationTitle(community.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

