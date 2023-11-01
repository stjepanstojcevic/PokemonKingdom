//
//  ViewModel.swift
//  PokemonKingdom
//
//  Created by Stjepan Stojčević on 01.11.2023..
//

import SwiftUI

class ViewModel: ObservableObject {

    @Published var pokemoni: [Pokemon] = []

    func fetch() {
        let pokemonCount = 1010
        let pokemonURLs = (1...pokemonCount).map { "https://ex.traction.one/pokedex/pokemon/\($0)" }

        let dispatchGroup = DispatchGroup()

        for url in pokemonURLs {
            dispatchGroup.enter()
            fetchPokemon(url: url, dispatchGroup: dispatchGroup)
        }

        dispatchGroup.notify(queue: .main) {
            print("All Pokemon data fetched.")
        }
    }

    private func fetchPokemon(url: String, dispatchGroup: DispatchGroup) {
        guard let url = URL(string: url) else {
            dispatchGroup.leave()
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            defer {
                dispatchGroup.leave()
            }

            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let decodedPokemon = try JSONDecoder().decode([Pokemon].self, from: data)
                DispatchQueue.main.async {
                    self?.pokemoni.append(contentsOf: decodedPokemon)
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}
