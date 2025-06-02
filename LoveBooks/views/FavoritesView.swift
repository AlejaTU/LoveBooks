//
//  FavoritesView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 2/6/25.
//

import SwiftUI

struct FavoritesView: View {
    @State private var userBooksVM = UserBooksViewModel()

    var body: some View {
        List(userBooksVM.favoriteBooks, id: \.id) { book in
            NavigationLink(destination: BookDetailView(book: book)) {
                HStack {
                    if let url = book.coverURL {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 50, height: 75)
                        .cornerRadius(4)
                    }

                    VStack(alignment: .leading) {
                        Text(book.title).font(.headline)
                        Text(book.author).font(.subheadline).foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Tus Favoritos")
        .task {
            await userBooksVM.fetchFavorites()
        }
    }
}

#Preview {
    FavoritesView()
}
