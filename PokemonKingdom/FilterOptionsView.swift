//
//  FilterOptionsView.swift
//  PokemonKingdom
//
//  Created by Stjepan Stojčević on 01.11.2023..
//

import SwiftUI

struct FilterOptionsView: View {
    //it creates instance of viewmodel that will be observed because it should be informed when @published objects from viewmodel would be changed
    @ObservedObject var viewModel: ViewModel
    let options: [String]
    //binding-used for two-way connection that allows data to be synchronized between different parts of code
    //changes in one location automatically will be reflected in another
    @Binding var selectedOption: String?
    @Binding var isFilterOptionsViewPresented: Bool
    //init-special method that is called during creating new instance of class or struct
    init(viewModel: ViewModel, options: [String], selectedOption: Binding<String?>, isFilterOptionsViewPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self.options = options
        _selectedOption = selectedOption //_selectedOption-property of the structure ; selectedOption-argument passed through the initializer
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
                    Spacer()
                    if selectedOption == option {
                        Image(systemName: "checkmark")
                        .foregroundColor(.gray)}
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

