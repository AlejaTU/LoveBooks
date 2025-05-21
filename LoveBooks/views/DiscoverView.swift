//
//  DiscoverView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 20/5/25.
//

import SwiftUI

struct DiscoverView: View {
    @State private var query = ""
       @State private var books: [Book] = []
       @State private var isLoading = false

       var body: some View {
           NavigationStack {
               VStack {
                   TextField("Buscar libros...", text: $query)
                       .padding()
                       .textFieldStyle(.roundedBorder)
                       .onSubmit {
                           Task {
                               await searchBooks()
                           }
                       }

                   if isLoading {
                       ProgressView()
                           .padding()
                   }

                   List(books) { book in
                       NavigationLink {
                           BookDetailView(book: book)
                       } label: {
                           HStack(alignment: .top) {
                               if let url = book.coverURL {
                                   AsyncImage(url: url) { image in
                                       image.resizable()
                                   } placeholder: {
                                       ProgressView()
                                   }
                                   .frame(width: 60, height: 90)
                                   .cornerRadius(8)
                               } else {
                                   Color.gray
                                       .frame(width: 60, height: 90)
                                       .cornerRadius(8)
                               }

                               VStack(alignment: .leading) {
                                   Text(book.title)
                                       .font(.headline)
                                   Text(book.author)
                                       .font(.subheadline)
                                       .foregroundColor(.secondary)
                               }
                           }
                           .padding(.vertical, 4)
                       }
                   }
                   .listStyle(.plain)
               }
               .navigationTitle("Descubrir libros")
           }
       }

       func searchBooks() async {
           guard !query.isEmpty else { return }
           isLoading = true

           do {
               let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
               let url = URL(string: "https://openlibrary.org/search.json?q=\(encodedQuery)")!

               let (data, _) = try await URLSession.shared.data(from: url)
               let result = try JSONDecoder().decode(OpenLibraryResponse.self, from: data)

               books = result.docs.map {
                   Book(
                       id: $0.key ?? UUID().uuidString,
                       title: $0.title ?? "Sin título",
                       author: $0.authorName?.first ?? "Autor desconocido",
                       coverURL: $0.coverI.flatMap {
                           URL(string: "https://covers.openlibrary.org/b/id/\($0)-M.jpg")
                       }
                   )
               }
           } catch {
               print("❌ Error al buscar libros:", error.localizedDescription)
           }

           isLoading = false
       }
   }

#Preview {
    DiscoverView()
}
