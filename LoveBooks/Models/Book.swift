//
//  Book.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 21/5/25.
//

import Foundation


struct Book: Identifiable, Codable {
    var id: String 
    var title: String
    var author: String
    var coverURL: URL?
}
