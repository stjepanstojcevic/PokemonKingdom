//
//  FilterOptionsView.swift
//  PokemonKingdom
//
//  Created by Stjepan Stojčević on 01.11.2023..
//

import SwiftUI

struct FilterOptionsView: View {
    @ObservedObject var viewModel: ViewModel
    let options: [String]
    @Binding var selectedOption: String?
    @State private var isFilterViewPresented: Bool = false

    init(viewModel: ViewModel, options: [String], selectedOption: Binding<String?>) {
        self.viewModel = viewModel
        self.options = options
        _selectedOption = selectedOption
    }

    var body: some View {
        VStack {
            List(options, id: \.self) { option in
                Button(action: {
                    selectedOption = option
                    viewModel.filterType = option
                }) {
                    HStack {
                        Image("Pokemon_Type_Icon_\(option)").resizable().frame(width: 30,height: 30)
                        Text(option)
                    }
                }
            }

            Button("Apply") {
                isFilterViewPresented.toggle()
            }
            .padding()
        }
        .sheet(isPresented: $isFilterViewPresented) {
        }
    }
}
