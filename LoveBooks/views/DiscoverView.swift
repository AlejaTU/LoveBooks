//
//  DiscoverView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 20/5/25.
//
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI



struct DiscoverView: View {
    @State private var query = ""
    @State private var searchText = ""
    @State private var books: [Book] = []
    @State private var isLoading = false
    @State private var searchTask: DispatchWorkItem?
    @State private var didLoad = false
    @State private var showingCategories = true
    
    
    
    private let categories: [DiscoverCategory] = [
        DiscoverCategory(id: "fiction", title: "Ficción", color: .purple.opacity(0.7), icon: "book.fill", query: "fiction"),
        DiscoverCategory(id: "romance", title: "Románticos", color: .pink.opacity(0.7), icon: "heart.fill", query: "romance"),
        DiscoverCategory(id: "biography", title: "Biografías", color: .orange.opacity(0.7), icon: "person.fill", query: "biography"),
        DiscoverCategory(id: "science", title: "Ciencia", color: .green.opacity(0.7), icon: "atom", query: "science"),
        DiscoverCategory(id: "history", title: "Historia", color: .blue.opacity(0.7), icon: "clock.arrow.circlepath", query: "history"),
        DiscoverCategory(id: "more", title: "Explorar más", color: .gray.opacity(0.3), icon: "ellipsis", query: "all")
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Buscar libros...", text: $searchText)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: searchText) {
                        scheduleSearch()
                    }
                
                if isLoading {
                    ProgressView().padding()
                }
                
                if !showingCategories && !books.isEmpty{
                    List(books) { book in
                        NavigationLink {
                            BookDetailView(book: book)
                        } label: {
                            HStack(alignment: .top) {
                                if let url = book.coverURL {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 60, height: 90)
                                    .cornerRadius(8)
                                } else {
                                    Color.gray
                                        .frame(width: 60, height: 90)
                                        .cornerRadius(8)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(book.title).font(.headline)
                                    Text(book.author).font(.subheadline).foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                            ForEach(categories) { category in
                                Button {
                                    showingCategories = false
                                    
                                    query = category.query
                                    Task { await searchBooks() }
                                } label: {
                                    VStack(spacing: 12) {
                                        Image(systemName: category.icon)
                                            .font(.largeTitle)
                                            .foregroundColor(.white)
                                        Text(category.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 120)
                                    .background(category.color)
                                    .cornerRadius(16)
                                    .shadow(radius: 4)
                                }
                            }
                        }
                        .padding()
                        NavigationLink {
                            DiscoverUsersView()
                        } label: {
                            HStack {
                                Image(systemName: "person.fill")
                                Text("Descubre lectores")
                            }
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(.top, 16)
                        }
                        .padding(.horizontal)
                        
                        NavigationLink {
                            CommunityListView()
                        } label: {
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .padding(4)
                                    .clipShape(Circle())
                                
                                Text("Comunidades")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(.top, 16)
                        }.padding(.horizontal)
                        
                    }
                }
            }
            .navigationTitle("Descubrir libros")
            .toolbar {
                if !showingCategories {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            books = []
                            searchText = ""
                            query = ""
                            showingCategories = true
                        } label: {
                            Image(systemName: "arrowshape.turn.up.backward")
                        }
                    }
                }
            }
            .task {
                if !didLoad && books.isEmpty && searchText.isEmpty {
                    didLoad = true
                    query = "fiction"
                    await searchBooks()
                }
            }
        }
    }
    
    
    func searchBooks() async {
        guard !query.isEmpty else { return }
        isLoading = true

        do {
            books = try await BookService.searchBooks(for: query)
        } catch {
            print("❌ Error al buscar libros:", error.localizedDescription)
        }

        isLoading = false
    }
    
    
    func scheduleSearch() {
        searchTask?.cancel()

        let task = DispatchWorkItem {
            Task {
                let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                query = text.isEmpty ? "fiction" : text

                showingCategories = false
                await searchBooks()
            }
        }

        searchTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
    }


    
}
    

#Preview {
    DiscoverView()
}
