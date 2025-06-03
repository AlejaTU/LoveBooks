//
//  MonthlyGoal.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 3/6/25.
//

import Foundation
import FirebaseFirestore

struct MonthlyGoal: Codable, Identifiable {
    @DocumentID var id: String?
    var goal: Int
    var createdAt: Date = Date()
}


// Modelo para el conteo anual de libros leídos

struct YearlyStats: Codable, Identifiable {
    @DocumentID var id: String? = nil
    var booksRead: Int
    var updatedAt: Date = Date()
}
