//
//  CircularProgressView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 3/6/25.
//

import SwiftUI

struct CircularProgressView: View {
    var current: Int
      var total: Int

      var progress: Double {
          guard total > 0 else { return 0 }
          return Double(current) / Double(total)
      }

      var body: some View {
          ZStack {
              Circle()
                  .stroke(lineWidth: 10)
                  .opacity(0.3)
                  .foregroundColor(.white)

              Circle()
                  .trim(from: 0.0, to: progress)
                  .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                  .foregroundColor(.green)
                  .rotationEffect(.degrees(-90))
                  .animation(.easeOut, value: progress)

              Text("\(Int(progress * 100))%")
                  .font(.headline)
                  .foregroundColor(.white)
          }
      }
  }

