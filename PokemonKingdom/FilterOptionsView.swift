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
    @Binding var isFilterOptionsViewPresented: Bool

    init(viewModel: ViewModel, options: [String], selectedOption: Binding<String?>, isFilterOptionsViewPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self.options = options
        _selectedOption = selectedOption
        _isFilterOptionsViewPresented = isFilterOptionsViewPresented
    }

    var body: some View {
        Text("Filter").padding()
            .foregroundColor(.gray)
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
            isFilterOptionsViewPresented = false
        }.padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(20)
    }
}

