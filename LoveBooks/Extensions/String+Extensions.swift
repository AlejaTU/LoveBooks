//
//  String+Extensions.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 19/5/25.
//
import Foundation

extension String {
    var isEmptyOrWhiteSpace: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    var hasUppercase: Bool {
            return range(of: "[A-Z]", options: .regularExpression) != nil
        }

        var hasNumber: Bool {
            return range(of: "[0-9]", options: .regularExpression) != nil
        }

        var hasSpecialCharacter: Bool {
            return range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        }
}
