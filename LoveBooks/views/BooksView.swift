//
//  BooksView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 20/5/25.
//

import SwiftUI

struct BooksView: View {
    @State private var favoriteCount = 0
       @State private var pendingCount = 0
       @State private var readCount = 0
    @State private var userBooksVM = UserBooksViewModel()

    
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                            VStack(spacing: 20) {
                                
                                // Favoritos
                                NavigationLink(destination: FavoritesView()) {
                                    BookSectionCard(
                                        title: "Favoritos",
                                        icon: "heart.fill",
                                        count: favoriteCount,
                                        gradient: LinearGradient(colors: [.white, .pink], startPoint: .top, endPoint: .bottom)
                                    )
                                }

                                //  Pendientes
                                NavigationLink(destination: PendingBooksView()) {
                                    BookSectionCard(
                                        title: "Pendientes",
                                        icon: "bookmark.fill",
                                        count: pendingCount,
                                        gradient: LinearGradient(colors: [.white, .blue], startPoint: .top, endPoint: .bottom)
                                    )
                                }
                                
                                NavigationLink(destination: ReadBooksView()) {
                                                        BookSectionCard(
                                                            title: "Leídos",
                                                            icon: "book.fill",
                                                            count: readCount,
                                                            gradient: LinearGradient(colors: [.white, .green], startPoint: .top, endPoint: .bottom)
                                                        )
                                                    }

                                Divider().padding(.vertical)

                                                  ReadingStatsView()
                                                      .padding(.horizontal)

                            }
                            .padding(.top)
                        }
                        .navigationTitle("Mis Libros")
                        .task {
                                      // Llamadas a las funcion de contar
                                      favoriteCount = await userBooksVM.countFavorites()
                                      pendingCount = await userBooksVM.countBooksWithStatus("pending")
                                      readCount = await userBooksVM.countBooksWithStatus("read")
                                  }
                    }
                }
            }

#Preview {
    BooksView()
}
