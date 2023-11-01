//
//  Pokemon.swift
//  PokemonKingdom
//
//  Created by Stjepan Stojčević on 01.11.2023..
//

import Foundation

struct Pokemon: Hashable, Codable {
    let number: Int
    let name: String
    let sprite: String
    let types: [String]

    private enum CodingKeys: String, CodingKey {
        case number
        case name
        case sprite
        case types
    }
}
