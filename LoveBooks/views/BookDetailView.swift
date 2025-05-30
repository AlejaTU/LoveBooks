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
    @State private var expandedReviewIDs: Set<String> = []
    @State private var selectedReviewForReply: Review? = nil
    @State private var showReplySheet = false
    @State private var userBooksVM = UserBooksViewModel()

    @State private var isFavorite = false
    
    func toggleFavorite() async {
        if isFavorite {
            await userBooksVM.removeFromFavorites(bookID: book.id)
            isFavorite = false
        } else {
            await userBooksVM.addToFavorites(book: book)
            isFavorite = true
        }
    }


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

                    HStack {
                        Text(book.title)
                            .font(.title)
                            .bold()

                        Spacer()

                        Button {
                            Task {
                                await toggleFavorite()
                            }
                        } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(.pink)
                        }
                    }


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
                                ReviewThreadView(
                                    review: review,
                                    expandedReviewIDs: $expandedReviewIDs,
                                    repliesByReview: $bookReviewsVM.repliesByReview,
                                    onReplyTapped: {
                                        selectedReviewForReply = review
                                        showReplySheet = true
                                    }
                                )
                                .task {
                                    if bookReviewsVM.repliesByReview[review.id ?? ""] == nil {
                                        await bookReviewsVM.loadReplies(for: review.id ?? "")
                                    }
                                }
                            }

                        }
                    }
                    .padding(.top)

                    Spacer()
                }
                .padding()
                .task {
                    await bookReviewsVM.fetchReviews(for: book.id)
                    isFavorite = await userBooksVM.isFavorite(bookID: book.id)

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
            .sheet(item: $selectedReviewForReply) { review in
                ReplySheetView(parentReviewID:  review.id ?? "")
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
