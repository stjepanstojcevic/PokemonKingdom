//
//  ContentView.swift
//  PokemonKingdom
//
//  Created by Stjepan Stojčević on 01.11.2023..
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ViewModel()

    @State private var searchText = ""
    @State private var currentPage = 1
    @State private var itemsPerPage = 18
    let totalPages = 57

    @State private var showFilterOptions = false
    @State private var selectedFilterOption: String? = nil
    let filterOptions = ["Normal", "Fire", "Water", "Grass", "Electric", "Ice", "Fighting", "Poison", "Ground", "Flying", "Psychic", "Bug", "Rock", "Ghost", "Dragon", "Dark", "Steel", "Fairy"]

    var visiblePokemon: [Pokemon] {
        if searchText.isEmpty {
            return viewModel.pokemoni
        } else {
            return viewModel.pokemoni.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    var filteredPokemon: [Pokemon] {
        guard viewModel.pokemoni.count == 1010 else {
            return []
        }

        if let selectedFilterOption = selectedFilterOption {
            return visiblePokemon.filter { $0.types.contains(selectedFilterOption) }
        } else {
            return visiblePokemon
        }
    }

    var visibleIndices: [Int] {
        let startIndex = (currentPage - 1) * itemsPerPage
        let endIndex = min(currentPage * itemsPerPage, filteredPokemon.count)
        return Array(startIndex..<endIndex)
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Search", text: $searchText)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    Spacer()
                    Button(action: {
                        showFilterOptions.toggle()
                    }) {
                        Text(selectedFilterOption ?? "Filter")
                    }
                    .sheet(isPresented: $showFilterOptions) {
                        FilterOptionsView(options: filterOptions, selectedOption: $selectedFilterOption)
                    }

                    Text("QR Code")
                }
                .padding()

                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 10) {
                        ForEach(visibleIndices, id: \.self) { index in
                            PokemonGridItem(pokemon: filteredPokemon[index])
                        }
                    }
                    .padding()
                }

                HStack {
                    Button(action: {
                        if currentPage > 1 {
                            currentPage -= 1
                        }
                    }) {
                        if (currentPage > 1) { Image(systemName: "arrow.left") }
                    }
                    Spacer()
                    Text("\(currentPage)")
                    Spacer()
                    Button(action: {
                        if currentPage < totalPages {
                            currentPage += 1
                        }
                    }) {
                        Image(systemName: "arrow.right")
                    }
                }
                .padding()
            }
            .onAppear {
                viewModel.fetch()
            }
        }
    }
}
