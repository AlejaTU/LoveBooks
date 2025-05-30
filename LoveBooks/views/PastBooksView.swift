//
//  PastBooksView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 29/5/25.
//

import SwiftUI



struct PastBooksView: View {
    let books: [MonthlyBook]

    var body: some View {
        NavigationStack {
            List(books) { book in
                HStack(alignment: .top, spacing: 12) {
                    if let urlString = book.coverURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 60, height: 90)
                        .clipped()
                        .cornerRadius(6)
                    } else {
                        Color.gray
                            .frame(width: 60, height: 90)
                            .cornerRadius(6)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(book.title)
                            .font(.headline)
                        Text(book.author)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Libros anteriores")
            .listStyle(.plain)
        }
    }
}

