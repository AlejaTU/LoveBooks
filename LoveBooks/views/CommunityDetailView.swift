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
    @State private var showPastBooksSheet = false
    @State private var showNewMonthAlert = false

    @State private var toastMessage: String?
    @State private var showToast = false
    @State private var isMember: Bool = false


    @ViewBuilder
    private func joinClubButton() -> some View {
        Button {
            Task {
                await monthlyBookVM.toggleMembership(for: community)
                isMember.toggle()
                toastMessage = isMember ? "🎉 Te has unido al club" : "👋 Has salido del club"
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showToast = false
                }
            }
        } label: {
            HStack {
                Image(systemName: isMember ? "checkmark.circle" : "person.badge.plus")
                Text(isMember ? "Perteneces a este club" : "Unirte al club")
                    .bold()
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isMember ? .green : .blue)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }


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
                    } else {
                        VStack(spacing: 12) {
                            //  Mostrar libro si existe
                            if let book = monthlyBookVM.currentMonthlyBook {
                                if let url = book.coverURL {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 100, height: 140)
                                    .cornerRadius(8)
                                }

                                Text(book.title)
                                    .font(.title2.bold())
                                Text("de \(book.author)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                //  Si no hay libro actual
                                Text("No se ha elegido libro para este mes.")
                                    .foregroundColor(.gray)

                                if isOwner {
                                    Button("Elegir libro del mes") {
                                        showSelectBookSheet = true
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }

                            //  Mostrar siempre el botón de unirse
                            joinClubButton()
                            // 🔁 Siempre mostrar botón de libros pasados
                            Button("Ver libros anteriores") {
                                Task {
                                    await monthlyBookVM.fetchPastBooks(for: community.id ?? "")
                                    showPastBooksSheet = true
                                }
                            }
                            .font(.subheadline)
                            .padding(.top, 8)
                            .sheet(isPresented: $showPastBooksSheet) {
                                PastBooksView(books: monthlyBookVM.pastMonthlyBooks)
                            }
                        }
                    }
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
            .alert("¡Nuevo mes detectado!", isPresented: $showNewMonthAlert) {
                Button("Vale", role: .cancel) { }
            } message: {
                Text("El libro anterior se ha movido a la lista de anteriores. Selecciona uno nuevo para este mes.")
            }


            .task {
                await monthlyBookVM.fetchCurrentBook(for: community.id ?? "")
                isMember = community.participants.contains(Auth.auth().currentUser?.uid ?? "")

                if monthlyBookVM.justMovedToPast {
                       showNewMonthAlert = true
                   }
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
