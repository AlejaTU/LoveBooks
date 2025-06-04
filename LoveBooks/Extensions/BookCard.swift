//
//  BookCard.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 2/6/25.
//

import SwiftUI

struct BookCard: View {
    let book: Book

       var body: some View {
           HStack(spacing: 12) {
               if let url = book.coverURL {
                   AsyncImage(url: url) { image in
                       image.resizable()
                           .scaledToFill()
                   } placeholder: {
                       Color.gray.opacity(0.3)
                   }
                   .frame(width: 60, height: 90)
                   .cornerRadius(8)
               }

               Text(book.title)
                   .font(.headline)
                   .lineLimit(1)

               Spacer()
           }
           .padding()
           .background(Color.white)
           .cornerRadius(12)
           .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
       }
   }
