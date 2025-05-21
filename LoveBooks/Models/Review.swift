//
//  Review.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 20/5/25.
//

import Foundation
import FirebaseFirestore

struct Review: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String
    var bookID: String
    var title: String
    var content: String
    var date: Date
}

