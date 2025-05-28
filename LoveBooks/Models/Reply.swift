//
//  Reply.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 28/5/25.
//
import Foundation
import SwiftUI


struct Reply: Identifiable, Codable {
    var id: String?
    var parentID: String
    var userID: String
    var content: String
    var date: Date
    var username: String?
    var photoURL: String?
}
