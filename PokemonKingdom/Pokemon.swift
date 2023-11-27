//
//  Pokemon.swift
//  PokemonKingdom
//
//  Created by Stjepan Stojčević on 01.11.2023..
//

import Foundation

struct Pokemon: Hashable, Codable { //these protocols enables hashing and en/decoding pokemons
    let number: Int
    let name: String
    let types: [String]
    let species: String
    let height: String
    let weight: String
    
    private enum CodingKeys: String, CodingKey {
        case number
        case name
        case types
        case species
        case height
        case weight
    }

}
