//
//  CommunityDetailView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 28/5/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct CommunityDetailView: View {
    let community: Community
    
    
    
    enum CommunityTab: String, CaseIterable {
        case book = "Libro del mes"
        case members = "Miembros"
    }

    @State private var selectedTab: CommunityTab = .book
    @State private var monthlyBookVM = MonthlyBookViewModel()
    @State private var showSelectBookSheet = false

    var isOwner: Bool {
        community.ownerID == Auth.auth().currentUser?.uid
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Selecciona", selection: $selectedTab) {
                    ForEach(CommunityTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == .book {
                    if monthlyBookVM.isLoading {
                        ProgressView("Cargando libro del mes...")
                    } else if let book = monthlyBookVM.currentMonthlyBook {
                        VStack(spacing: 12) {
                            if let url = book.coverURL {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 100, height: 140) // Tamaño miniatura
                                .cornerRadius(8)
                            }

                            Text(book.title)
                                .font(.title2.bold())
                            Text("de \(book.author)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Button("Ver libros anteriores") {
                                // lógica futura
                            }
                            .padding(.top)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Text("No se ha elegido libro para este mes.")
                                .foregroundColor(.gray)
                            if isOwner {
                                Button("Elegir libro del mes") {
                                    showSelectBookSheet = true
                                }
                                .buttonStyle(.borderedProminent)
                                
                            }
                        }
                    }
                } else {
                    Text("Aquí irán los miembros.")
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .navigationTitle(community.name)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSelectBookSheet) {
                SelectMonthlyBookView(
                    onBookSelected: { book in
                        Task {
                            await monthlyBookVM.addMonthlyBook(for: community.id ?? "", book: book)
                            await monthlyBookVM.fetchCurrentBook(for: community.id ?? "")
                            showSelectBookSheet = false
                        }
                    }
                )
            }

            .task {
                await monthlyBookVM.fetchCurrentBook(for: community.id ?? "")
            }
        }
    }
}

#Preview {
    CommunityDetailView(community: Community(
           id: "demo123",
           name: "Club de Lectura Swift",
           description: "Un grupo para amantes de la programación en Swift",
           ownerID: "user123",
           createdAt: Date(),
           bookOfTheMonthID: nil,
           participants: []
       ))
}
