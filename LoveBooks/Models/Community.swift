//
//  Community.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 28/5/25.
//

import Foundation
import FirebaseFirestore

struct Community: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var ownerID: String
    var createdAt: Date
    var bookOfTheMonthID: String?
    var participants: [String]
}
