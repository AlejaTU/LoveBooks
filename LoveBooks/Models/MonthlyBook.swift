//
//  Untitled.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 28/5/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore


struct MonthlyBook: Identifiable, Codable {
    @DocumentID var id: String?
    
    var bookID: String           // ID real del libro
    var title: String
    var author: String
    var coverURL: String?       
    var addedAt: Date            // Fecha de selección del libro

    var monthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: addedAt)
    }
}
