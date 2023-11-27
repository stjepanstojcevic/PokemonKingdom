//
//  ViewModel.swift
//  PokemonKingdom
//
//  Created by Stjepan Stojčević on 01.11.2023..
//

import SwiftUI

class ViewModel: ObservableObject { //it enables tracking changes and informing user about these changes
    //any changes of these variables will be forwarded to subscribed objects/views
    @Published var pokemoni: [Pokemon] = []
    @Published var filterType: String? = nil

    var filterOptions: [String] {
        Set(pokemoni.flatMap { $0.types }).sorted()
    }

    var filteredPokemoni: [Pokemon] {
        if let filterType = filterType {
            return pokemoni.filter { $0.types.contains(filterType) }
        } else {
            return pokemoni
        }
    }

    func fetch() { //function for asynchronous fetching pokemons data from given urls
        let pokemonCount = 1010
        let pokemonURLs = (1...pokemonCount).map { "https://ex.traction.one/pokedex/pokemon/\($0)" }
        //DispatchGroup-part of Grand Central Dispatch
        //it's used for synchronize asynchronous tasks
        //I used it to wait for all fetching pokemons data be completed before the rest of the code
        let dispatchGroup = DispatchGroup()

        for url in pokemonURLs {
            dispatchGroup.enter() //signalizing that the task has entered the group and it starts executing
            fetchPokemon(url: url, dispatchGroup: dispatchGroup)
        }
    }

    private func fetchPokemon(url: String, dispatchGroup: DispatchGroup) {
        guard let url = URL(string: url) else { //it creates url objects from strings
            dispatchGroup.leave() //signalizing that the task has finished and can leave the group
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in //it execute asynchronous http request for fetching data from given url
            defer { //it is used to guarantee that next line will be executed no matter of success of http requesting
                dispatchGroup.leave()
            }

            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {//JSONDecoder-it is used to convert json data to useable swift objects (etc. Pokemon object)
                let decodedPokemon = try JSONDecoder().decode([Pokemon].self, from: data)
                DispatchQueue.main.async {
                    self?.pokemoni.append(contentsOf: decodedPokemon)
                }
            } catch {
                print("")
            }
        }
        task.resume()
    }
}
