//
//  SelectMonthlyBookView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 28/5/25.
//

import SwiftUI
import SwiftUI

struct SelectMonthlyBookView: View {
    @Environment(\.dismiss) var dismiss

    @State private var searchText = ""
    @State private var books: [Book] = []
    @State private var isLoading = false
    @State private var searchTask: DispatchWorkItem?
    
    @State private var selectedBook: Book?
    @State private var showConfirmation = false


    let onBookSelected: (Book) -> Void

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Buscar libro...", text: $searchText)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: searchText) {
                        scheduleSearch()
                    }

                if isLoading {
                    ProgressView("Buscando...")
                        .padding()
                }

                List(books) { book in
                    Button {
                        selectedBook = book
                            showConfirmation = true
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            if let url = book.coverURL {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 60, height: 90)
                                .clipped()
                                .cornerRadius(6)
                            } else {
                                Color.gray
                                    .frame(width: 60, height: 90)
                                    .cornerRadius(6)
                            }

                            VStack(alignment: .leading) {
                                Text(book.title)
                                    .font(.headline)
                                Text(book.author)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Elegir libro")
            .alert("¿Agregar este libro como el libro del mes?", isPresented: $showConfirmation, presenting: selectedBook) { book in
                Button("Aceptar") {
                    onBookSelected(book)
                    dismiss()
                }
                Button("Cancelar", role: .cancel) { }
            } message: { book in
                Text("\"\(book.title)\" de \(book.author)")
            }

            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }

    func scheduleSearch() {
        searchTask?.cancel()

        let task = DispatchWorkItem {
            Task {
                await searchBooks()
            }
        }

        searchTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: task)
    }

    func searchBooks() async {
        guard !searchText.isEmpty else {
            books = []
            return
        }

        isLoading = true
        do {
            books = try await BookService.searchBooks(for: searchText)
        } catch {
            print("❌ Error al buscar:", error.localizedDescription)
            books = []
        }
        isLoading = false
    }
}

#Preview {
    SelectMonthlyBookView { book in
            print("Seleccionado: \(book.title)")
        }
}
