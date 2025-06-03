//
//  ReadBooksView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 2/6/25.
//

import SwiftUI

struct ReadBooksView: View {
    @State private var readBooks: [UserBook] = []
    @State private var userBooksVM = UserBooksViewModel()

    let columns = [
        GridItem(.flexible(),spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(readBooks, id: \.id) { userBook in
                    VStack(spacing: 8) {
                        if let url = userBook.book.coverURL {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 110)
                                    .cornerRadius(8)
                                    .shadow(radius: 3)
                            } placeholder: {
                                Color.gray.opacity(0.2)
                                    .frame(height: 110)
                                    .cornerRadius(8)
                            }
                        }
                        
                        
                        Text(userBook.book.title)
                                                   .font(.footnote)
                                                   .fontWeight(.semibold)
                                                   .lineLimit(2)
                                                   .multilineTextAlignment(.center)
                                                   .foregroundColor(.primary)

                        Text(fechaFormateada(userBook.dateAdded))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Leídos")
        .task {
            readBooks = await userBooksVM.fetchBooksByStatus("read")
        }
    }

    func fechaFormateada(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
#Preview {
    ReadBooksView()
}
