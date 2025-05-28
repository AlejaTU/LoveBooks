//
//  ReviewThreadView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 28/5/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

import SwiftUI

struct ReviewThreadView: View {
    let review: Review
    @Binding var expandedReviewIDs: Set<String>
    @Binding var repliesByReview: [String: [Reply]]
    var onReplyTapped: () -> Void

    var body: some View {
        if let reviewID = review.id {
            VStack(alignment: .leading, spacing: 8) {
                // Foto y nombre
                HStack(alignment: .center, spacing: 8) {
                    if let urlString = review.photoURL,
                       let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Circle().fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 36, height: 36)
                    }

                    Text(review.username ?? "Usuario desconocido")
                        .font(.subheadline)
                        .bold()
                }

                // Título del libro
                if !review.title.isEmpty {
                    HStack {
                        Text(review.title)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Spacer()

                        Button {
                            onReplyTapped()
                        } label: {
                            Image(systemName: "bubble.left")
                                .font(.subheadline)
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.gray)
                    }
                }

                // Contenido
                Text(review.content)
                    .font(.body)
                    .foregroundColor(.primary)

                // Ver respuestas
                if let replies = repliesByReview[reviewID], !replies.isEmpty {
                    if !expandedReviewIDs.contains(reviewID) {
                        Button("Ver respuestas (\(replies.count))") {
                            withAnimation {
                              _ =  expandedReviewIDs.insert(reviewID)
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }

                // Mostrar respuestas si está expandido
                if expandedReviewIDs.contains(reviewID) {
                    let replies = repliesByReview[reviewID] ?? []

                    ForEach(replies.prefix(5)) { reply in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(reply.username ?? "Usuario")
                                    .font(.caption)
                                    .bold()
                                Spacer()
                                Text(reply.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }

                            Text(reply.content)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        .padding(8)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(6)
                        .padding(.leading, 8)
                    }

                    if replies.count > 5 {
                        Text("Mostrar más respuestas...")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }

                // Fecha y libro
                HStack {
                    Text(review.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)

                    Spacer()

                    if let bookTitle = review.bookTitle {
                        Text("📚 \(bookTitle)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.vertical, 8)
        } else {
            EmptyView()
        }
    }
}

