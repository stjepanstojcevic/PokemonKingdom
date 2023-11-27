//
//  ContentView.swift
//  PokemonKingdom
//
//  Created by Stjepan Stojčević on 01.11.2023..
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ViewModel()

    @State private var searchText = ""
    @State private var currentPage = 1
    @State private var itemsPerPage = 18
    let totalPages = 57

    @State private var showQR = false
    @State private var showFilterOptions = false
    @State private var selectedFilterOption: String? = nil
    let filterOptions = ["Normal","Fire","Water","Grass","Electric","Ice","Fighting","Poison","Ground","Flying","Psychic","Bug","Rock","Ghost","Dragon","Dark","Steel","Fairy"]

    @State private var scannedNumbers: [Int] = []

    var visiblePokemon: [Pokemon] { //function just for searchbar
        if searchText.isEmpty {
            return viewModel.filteredPokemoni
        } else {
            return viewModel.filteredPokemoni.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    var visibleIndices: [Int] {
        let startIndex = (currentPage - 1) * itemsPerPage
        let endIndex = min(currentPage * itemsPerPage, visiblePokemon.count)
        return Array(startIndex..<endIndex)
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    HStack{ Image(systemName: "magnifyingglass").foregroundColor(.gray)
                            TextField("Search...", text: $searchText).padding(8)
                    }.background(Color(.systemGray6)).cornerRadius(8)

                    Spacer()
                    //toggle()-it changes true to false and false to true
                    //action-it says what will happend when user click the button
                    Button(action: { showFilterOptions.toggle()}) {Image(systemName: "line.3.horizontal.decrease.circle").foregroundColor(.black)}
                    //.sheet-modifier that takes 2 parameter, boolean and content of modal view which will be presented only if the boolean is true
                    //-allows dynamic presentation based on changes of the boolean
                    //$-this is way to access real data of state variable
                    .sheet(isPresented: $showFilterOptions) {
                        FilterOptionsView(viewModel: viewModel, options: filterOptions, selectedOption: $selectedFilterOption, isFilterOptionsViewPresented: $showFilterOptions)}

                    Button(action: {showQR.toggle()}){ Image(systemName: "qrcode").foregroundColor(.black)}.sheet(isPresented: $showQR) {
                        QRView(viewModel: viewModel, scannedNumbers: $scannedNumbers)}
                }.padding()

                ScrollView { //it is a container for showing data in grid with changable number of columns
                             //lazy word means it generates data only if it is needed so it's optimized for big data
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 10) {
                        ForEach(visibleIndices, id: \.self) { index in
                            PokemonGridItem(pokemon: visiblePokemon[index], scannedNumbers: $scannedNumbers, viewModel: viewModel) }
                    }.padding() }

                HStack {
                    Button(action: {
                        if currentPage > 1 { currentPage -= 1 } })
                    {
                        if (currentPage > 1) { Image(systemName: "arrowshape.left").foregroundColor(.gray) }
                    }
                    
                    Spacer()
                    
                    Text("\(currentPage)")
                    
                    Spacer()
                    
                    Button(action: {
                        if currentPage < totalPages {  currentPage += 1 } })
                    {
                        Image(systemName: "arrowshape.right").foregroundColor(.gray) 
                    }
                }.padding()
            }.onAppear { viewModel.fetch() }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
