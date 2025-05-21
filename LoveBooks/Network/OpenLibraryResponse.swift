//
//  OpenLibraryResponse.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 21/5/25.
//


struct OpenLibraryResponse: Codable {
    let docs: [OpenLibraryDoc]
}

struct OpenLibraryDoc: Codable {
    let key: String?
    let title: String?
    let authorName: [String]?
    let coverI: Int?

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorName = "author_name"
        case coverI = "cover_i"
    }
}
