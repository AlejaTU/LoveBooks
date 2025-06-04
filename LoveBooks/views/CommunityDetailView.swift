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

    var isOwner: Bool {
        community.ownerID == Auth.auth().currentUser?.uid
    }

    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    // ─── Picker de pestañas ────────────────────────────
                    Picker("Selecciona", selection: $selectedTab) {
                        ForEach(CommunityTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    // ─── Contenido de “Libro del mes” ─────────────────
                    if selectedTab == .book {
                        if monthlyBookVM.isLoading {
                            ProgressView("Cargando libro del mes...")
                        } else {
                            VStack(spacing: 12) {
                                // Mostrar libro si existe
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
                                    // Si no hay libro actual
                                    Text("No se ha elegido libro para este mes.")
                                        .foregroundColor(.gray)

                                    if isOwner {
                                        Button("Elegir libro del mes") {
                                            showSelectBookSheet = true
                                        }
                                        .buttonStyle(.borderedProminent)
                                    }
                                }

                                // Botón de unirse al club
                                joinClubButton()

                                // Botón para ver libros anteriores
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
                            .padding(.top, 16)
                        }
                    }
                    // ─── Contenido de “Miembros” ───────────────────────
                    else if selectedTab == .members {
                        if monthlyBookVM.members.isEmpty {
                            Text("No hay miembros en este club.")
                                .foregroundColor(.gray)
                                .padding()
                                .task {
                                    await monthlyBookVM.fetchParticipants(for: community)
                                }
                        } else {
                            List(monthlyBookVM.members) { user in
                                HStack {
                                    if let urlString = user.photoURL,
                                       let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                    } else {
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 40, height: 40)
                                    }

                                    VStack(alignment: .leading) {
                                        Text(user.username)
                                            .font(.headline)
                                        if !user.bio.isEmpty {
                                            Text(user.bio)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .task {
                                await monthlyBookVM.fetchParticipants(for: community)
                            }
                        }
                    }

                    Spacer()
                }
                .navigationTitle(community.name)
                .navigationBarTitleDisplayMode(.inline)
                // Carga inicial al aparecer la vista
                .task {
                    await monthlyBookVM.fetchCurrentBook(for: community.id ?? "")
                    // Verificar si el usuario ya forma parte de participants
                    let currentUID = Auth.auth().currentUser?.uid ?? ""
                    isMember = community.participants.contains(currentUID)
                    if monthlyBookVM.justMovedToPast {
                        showNewMonthAlert = true
                    }
                }
                // Cuando cambiamos a pestaña “Miembros”, recargamos la lista
                .onChange(of: selectedTab) { newTab in
                    if newTab == .members {
                        Task {
                            await monthlyBookVM.fetchParticipants(for: community)
                        }
                    }
                }
                // Cuando consumamos toggleMembership, recargamos lista
                .onChange(of: isMember) { _ in
                    Task {
                        await monthlyBookVM.fetchParticipants(for: community)
                    }
                }
                // Hoja para seleccionar libro del mes
                .sheet(isPresented: $showSelectBookSheet) {
                    SelectMonthlyBookView(
                        onBookSelected: { book in
                            Task {
                                await monthlyBookVM.addMonthlyBook(
                                    for: community.id ?? "",
                                    book: book
                                )
                                await monthlyBookVM.fetchCurrentBook(
                                    for: community.id ?? ""
                                )
                                showSelectBookSheet = false
                            }
                        }
                    )
                }
                // Alerta de mes nuevo
                .alert("¡Nuevo mes detectado!", isPresented: $showNewMonthAlert) {
                    Button("Vale", role: .cancel) { }
                } message: {
                    Text("El libro anterior se ha movido a la lista de anteriores. Selecciona uno nuevo para este mes.")
                }
            }

            // ─── TOAST (mensaje emergente) ─────────────────────────
            if showToast, let message = toastMessage {
                VStack {
                    ToastView(message: message)
                        .padding(.top, 60) // Ajusta según safe area
                    Spacer()
                }
                .animation(.easeInOut(duration: 0.3), value: showToast)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // ─── BOTÓN “UNIRTE AL CLUB” ────────────────────────────
    @ViewBuilder
    private func joinClubButton() -> some View {
        Button {
            Task {
                // 1) Cambiar membresía en Firestore
                await monthlyBookVM.toggleMembership(for: community)
                // 2) Actualizar variable local para cambiar estado del botón e invocar onChange
                isMember.toggle()
                // 3) Preparar mensaje toast
                toastMessage = isMember
                    ? "🎉 Te has unido al club"
                    : "👋 Has salido del club"
                showToast = true
                // 4) Ocultar toast tras 2.5 segundos
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showToast = false
                }
                // 5) Refrescar automáticamente la lista de miembros
                await monthlyBookVM.fetchParticipants(for: community)
            }
        } label: {
            HStack {
                Image(systemName: isMember
                            ? "checkmark.circle"
                            : "person.badge.plus")
                Text(isMember
                        ? "Perteneces a este club"
                        : "Unirte al club")
                    .bold()
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isMember ? Color.green : Color.blue)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

// ─── TOASTVIEW: Vista sencilla para mostrar el mensaje ─────
struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .shadow(radius: 4)
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
