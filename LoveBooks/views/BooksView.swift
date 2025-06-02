//
//  BooksView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 20/5/25.
//

import SwiftUI

struct BooksView: View {
    var body: some View {
        NavigationStack {
                    VStack(spacing: 20) {
                        NavigationLink(destination: FavoritesView()) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.pink)
                                    .font(.title)
                                    .padding()

                                VStack(alignment: .leading) {
                                    Text("Favoritos")
                                        .font(.headline)
                                    Text("Tus libros favoritos")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                        }
                    }
                    .navigationTitle("Mis Libros")
                }
            }
        }

#Preview {
    BooksView()
}
