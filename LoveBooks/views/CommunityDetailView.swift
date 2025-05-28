//
//  CommunityDetailView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 28/5/25.
//

import SwiftUI


struct CommunityDetailView: View {
    let community: Community
    
    
    
    enum CommunityTab: String, CaseIterable {
        case book = "Libro del mes"
        case members = "Miembros"
    }

    @State private var selectedTab: CommunityTab = .book

    
    
    var body: some View {
        NavigationStack {
            VStack {
                // Pestañas
                Picker("Selecciona", selection: $selectedTab) {
                    ForEach(CommunityTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // Contenido según la pestaña
                if selectedTab == .book {
                    VStack(spacing: 12) {
                        Text("Aquí irá el libro del mes 📖")
                            .font(.title3)
                            .foregroundColor(.gray)
                        // Aquí luego se puede mostrar el MonthlyBookView
                    }
                } else {
                    VStack(spacing: 12) {
                        Text("Aquí aparecerán los miembros 👥")
                            .font(.title3)
                            .foregroundColor(.gray)
                        // Aquí luego se puede mostrar la lista de participantes
                    }
                }

                Spacer()
            }
            .navigationTitle(community.name)
            .navigationBarTitleDisplayMode(.inline)
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
