//
//  BookSectionCard.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 2/6/25.
//

import SwiftUI

struct BookSectionCard: View {
    var title: String
        var icon: String
        var count: Int
        var gradient: LinearGradient

        var body: some View {
            ZStack(alignment: .bottomLeading) {
                gradient
                    .frame(height: 120)
                    .cornerRadius(20)
                    .shadow(radius: 5)

                VStack(alignment: .center, spacing: 4) {
                    
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        

                    HStack (alignment: .bottom) {
                        
                        

                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(.white)
                        Spacer()
                        
                        Text("\(count) libros")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                 
                }
                .padding()
            }
            .padding(.horizontal)
        }
    }
