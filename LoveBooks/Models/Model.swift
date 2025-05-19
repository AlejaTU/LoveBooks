//
//  Model.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 19/5/25.
//

import Foundation
import FirebaseAuth


@MainActor
@Observable
class Model {
    
    init() {}


    func updateDisplayName(for user: User, displayName: String) async throws {
        let request = user.createProfileChangeRequest()
        request.displayName = displayName
        try await request.commitChanges()
    }
    
}
