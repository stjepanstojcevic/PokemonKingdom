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

    var body: some View {
        VStack {
            if let spriteImage = spriteImage {
                Image(uiImage: spriteImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .background(Color(hue: 1.0, saturation: 0.026, brightness: 0.859))
                    .cornerRadius(20)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 95, height: 95)
                    .background(Color.gray)
            }

            Text("\(pokemon.number). \(pokemon.name)")
                .bold()
                .multilineTextAlignment(.center)
                .padding(3)
        }
        .onAppear {
            fetchSpriteImage()
        }
    }

    private func fetchSpriteImage() {
        guard let url = URL(string: pokemon.sprite) else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }

            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    spriteImage = image
                }
            }
        }.resume()
    }
}
