//
//  CommunityListView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 28/5/25.
//

import SwiftUI

struct CommunityListView: View {
    @State private var showCreateSheet = false
    @State private var viewModel = CommunityViewModel()
    @State private var searchText = ""

    var filteredCommunities: [Community] {
        if searchText.isEmpty {
            return viewModel.communities
        } else {
            return viewModel.communities.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var communityList: some View {
        List {
            ForEach(filteredCommunities) { community in
                NavigationLink(destination: CommunityDetailView(community: community)) {
                    VStack(alignment: .leading) {
                        Text(community.name)
                            .font(.headline)
                        Text(community.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onDelete(perform: deleteCommunity)
        }
        .searchable(text: $searchText, prompt: "Buscar comunidades")
        .listStyle(.insetGrouped)
    }

    func deleteCommunity(at offsets: IndexSet) {
        for index in offsets {
            let community = filteredCommunities[index]
            if community.ownerID == viewModel.currentUserID {
                Task {
                    await viewModel.deleteCommunity(community)
                    await viewModel.fetchCommunities()
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Cargando comunidades...")
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.communities.isEmpty {
                    Text("No hay comunidades aún.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    communityList
                }

                Spacer()
            }
            .navigationTitle("Club de Lectura")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showCreateSheet = true
                    }) {
                        Label("Crear comunidad", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateCommunityView(viewModel: viewModel)
            }
            .task {
                await viewModel.fetchCommunities()
            }
        }
    }
}




#Preview {
    CommunityListView()
    
}
