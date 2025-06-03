//
//  PendingBooksView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 2/6/25.
//

import SwiftUI


struct PendingBooksView: View {
    @State private var pendingBooks: [UserBook] = []
    @State private var userBooksVM = UserBooksViewModel()
    @State private var showConfirmation = false
    @State private var selectedBook: UserBook?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(pendingBooks, id: \.id) { userBook in
                    ZStack {
                        BookCard(book: userBook.book)
                    }
                    .contentShape(Rectangle())
                    .onLongPressGesture {
                        selectedBook = userBook
                        showConfirmation = true
                    }

                }
            }
            .padding()
        }
        .navigationTitle("Pendientes")
        .task {
            pendingBooks = await userBooksVM.fetchBooksByStatus("pending")
        }
        .confirmationDialog("¿Marcar como leído?", isPresented: $showConfirmation, titleVisibility: .visible) {
            Button("Si, marcar como leído", role: .destructive) {
                Task {
                    if let book = selectedBook {
                        await userBooksVM.updateBookStatus(bookID: book.id ?? "", newStatus: "read")
                        pendingBooks.removeAll { $0.id == book.id }
                    }
                }
            }
            Button("Cancelar", role: .cancel) { }
        }
    }
}
#Preview {
    PendingBooksView()
}
