//
//  FollowedItem.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 20/5/25.
//

import Foundation
import FirebaseFirestore 

struct FollowedItem: Identifiable, Codable {
    var id: String? = UUID().uuidString
    var followerID: String
    var type: FollowType
    var targetID: String
    var date: Date
}

enum FollowType: String, Codable {
    case user
    case book
}
