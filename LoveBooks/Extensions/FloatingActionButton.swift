//
//  FloatingActionButton.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 22/5/25.
//

import SwiftUI

struct FloatingActionButton: View {
    let action: () -> Void
    let icon: String

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.system(size: 24))
                .frame(width: 56, height: 56)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .padding()
    }
}

#Preview {
    FloatingActionButton(action: {}, icon: "plus")
}
