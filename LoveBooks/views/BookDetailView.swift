//
//  BookDetailView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 21/5/25.
//

import SwiftUI

struct BookDetailView: View {
    let book: Book

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Portada del libro
                    if let url = book.coverURL {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(10)
                                .shadow(radius: 4)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Color.gray
                            .frame(height: 250)
                            .cornerRadius(10)
                            .overlay(Text("Sin portada").foregroundColor(.white))
                    }

                    // Título y autor
                    Text(book.title)
                        .font(.title)
                        .bold()

                    Text("por \(book.author)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Divider()

                    // Espacio para futuras acciones
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📌 Aquí irán:")
                        Text("• Botón para añadir reseña")
                        Text("• Botón para marcar como favorito")
                        Text("• Lista de reseñas si las hay")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Libro")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

