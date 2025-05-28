//
//  BookDetailView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 21/5/25.
//

import SwiftUI

struct BookDetailView: View {
    let book: Book
        @State private var showAddReviewSheet = false
        @State private var bookReviewsVM = BookReviewsViewModel()
    
    

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Portada del libro
                    if let url = book.coverURL {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .scaledToFit()
                        .cornerRadius(10)
                        .shadow(radius: 4)
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

                    // Botón Añadir reseña
                    Button(action: {
                        showAddReviewSheet = true
                    }) {
                        Label("Añadir reseña", systemImage: "square.and.pencil")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(radius: 3)
                    }

                    // Lista de reseñas recuperadas desde Firestore
                    VStack(alignment: .leading, spacing: 12) {
                        if bookReviewsVM.isLoading {
                            ProgressView("Cargando reseñas...")
                                .padding()
                        } else if !bookReviewsVM.errorMessage.isEmpty {
                            Text(bookReviewsVM.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        } else if bookReviewsVM.reviews.isEmpty {
                            Text("No hay reseñas aún.")
                                .foregroundColor(.secondary)
                        } else {
                            Text("Reseñas recientes")
                                .font(.headline)
                                .foregroundStyle(Color.gray)
                                .padding(.top)

                            ForEach(bookReviewsVM.reviews) { review in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(review.title)
                                        .font(.subheadline.bold())
                                    Text(review.content)
                                        .font(.body)
                                    Text(review.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Divider()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding(.top)

                    Spacer()
                }
                .padding()
                .task {
                    await bookReviewsVM.fetchReviews(for: book.id)
                }
            }
            .navigationTitle("Libro")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddReviewSheet, onDismiss: {
                Task {
                    await bookReviewsVM.fetchReviews(for: book.id) // actualiza después de añadir reseña
                }
            }) {
                AddReviewView(book: book)
            }
        }
    }
   #Preview {
       BookDetailView(book: Book(
           id: "OL12345M",
           title: "El Principito",
           author: "Antoine de Saint-Exupéry",
           coverURL: nil
       ))
   }
