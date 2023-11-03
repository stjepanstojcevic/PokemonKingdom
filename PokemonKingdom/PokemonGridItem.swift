//
//  PokemonGridItem.swift
//  PokemonKingdom
//
//  Created by Stjepan Stojčević on 01.11.2023..
//

import SwiftUI

struct PokemonGridItem: View {
    let pokemon: Pokemon
    @State private var spriteImage: UIImage? = nil
    @State private var isScanned: Bool = false
    @Binding var scannedNumbers: [Int]
    @ObservedObject var viewModel: ViewModel
    var selectedFilterOption: String?

    var body: some View {
        VStack {
            if isScanned, let spriteImage = spriteImage, viewModel.filteredPokemoni.contains(pokemon) && (selectedFilterOption == nil || pokemon.types.contains(selectedFilterOption!)) {
                Image(uiImage: spriteImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .background(Color.black)
                    .cornerRadius(20)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color.gray)
                    .overlay(
                        Text("Pokemon Kingdom")
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    )
            }
            ///Text("\(pokemon.number). \(pokemon.name)").bold().multilineTextAlignment(.center).padding(3)
        }
        .onAppear {
            guard let url = URL(string: "https://img.pokemondb.net/sprites/home/normal/\(pokemon.name.lowercased()).png") else {
                return
            }

            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else { return }

                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        spriteImage = image
                        isScanned = scannedNumbers.contains(pokemon.number)
                    }
                }
            }.resume()
        }
    }
}

