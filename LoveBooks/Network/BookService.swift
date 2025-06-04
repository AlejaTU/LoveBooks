//
//  Network.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 28/5/25.
//

import Foundation
import SwiftUI
import FirebaseStorage




struct BookService {
    static func searchBooks(for query: String) async throws -> [Book] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "https://openlibrary.org/search.json?q=\(encodedQuery)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let result = try JSONDecoder().decode(OpenLibraryResponse.self, from: data)

        return result.docs.map {
            Book(
                id: $0.key ?? UUID().uuidString,
                title: $0.title ?? "Sin título",
                author: $0.authorName?.first ?? "Autor desconocido",
                coverURL: $0.coverI.flatMap {
                    URL(string: "https://covers.openlibrary.org/b/id/\($0)-M.jpg")
                }
            )
        }
    }
}

