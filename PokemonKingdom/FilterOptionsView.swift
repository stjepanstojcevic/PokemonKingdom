//
//  FilterOptionsView.swift
//  PokemonKingdom
//
//  Created by Stjepan Stojčević on 01.11.2023..
//

import SwiftUI

struct FilterOptionsView: View {
    let options: [String]
    @Binding var selectedOption: String?

    var body: some View {
        List(options, id: \.self) { option in
            Button(action: {
                selectedOption = option
            }) {
                HStack{
                    Image("Pokemon_Type_Icon_\(option)").resizable().frame(width: 30,height: 30)
                    Text(option)}
            }
        }
    }
}
