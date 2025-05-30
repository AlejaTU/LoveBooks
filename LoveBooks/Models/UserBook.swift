//
//  UserBook.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 30/5/25.
//

import Foundation
import FirebaseFirestore

struct UserBook: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String
    var book: Book
    var status: String
    var dateAdded: Date
}
