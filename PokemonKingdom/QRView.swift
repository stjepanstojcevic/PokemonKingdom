//
//  QRView.swift
//  PokemonKingdom
//
//  Created by Stjepan Stojčević on 02.11.2023..
//

import SwiftUI
import Foundation //library that gives us access to functionalities by FoundationFramework
                  //I used it for URL and UserDefaults

struct QRView: View {
    @State private var selectedImage: UIImage? = nil
    @State private var selectedPokemon: Pokemon? = nil
    @State private var imageURLString: String = ""
    @State private var isImagePickerPresented: Bool = false
    @State private var qrCodeContent: String? = nil
    @State private var scannedPokemonName: String? = nil
    @State private var scannedPokemonSpecies: String? = nil
    @State private var scannedPokemonHeight: String? = nil
    @State private var scannedPokemonWeight: String? = nil

    @Binding var scannedNumbers: [Int]
    @ObservedObject var viewModel: ViewModel

    init(viewModel: ViewModel, scannedNumbers: Binding<[Int]>) {
        self.viewModel = viewModel
        _scannedNumbers = scannedNumbers
    }

    var body: some View {
        VStack {
            //map function cast int to string and joined function just concatenate all strings and separate them with comma
            Text("Scanned Pokemons: \(scannedNumbers.map(String.init).joined(separator: ", "))")

            if selectedPokemon != nil {
                //AsyncImage is function for asynchronous loading image from a given url
                AsyncImage(url: URL(string: "https://img.pokemondb.net/sprites/home/normal/\(scannedPokemonName?.lowercased() ?? "").png")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .background(Color.gray)
                            .cornerRadius(20)
                    case .failure:
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color.gray)
                            .overlay(
                                Text("No selected image")
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            )
                    case .empty: //the image not available
                        ProgressView() //this is swiftui component that visually shows progress or ongoing activity
                    @unknown default: //unknown error, just in case
                        EmptyView()
                    }
                }
                
                if let qrCodeContent = qrCodeContent { //this if check is qrCodeContent nil or it has value and then gives value species, height adn weight
                    Text(qrCodeContent)

                    if let scannedPokemonSpecies = scannedPokemonSpecies {
                        Text("Species: \(scannedPokemonSpecies)")
                    }
                    if let scannedPokemonHeight = scannedPokemonHeight {
                        Text("Height: \(scannedPokemonHeight)")
                    }
                    if let scannedPokemonWeight = scannedPokemonWeight {
                        Text("Weight: \(scannedPokemonWeight)")
                    }
                } else {
                    Text("No number")
                        .padding()
                }
            } else {
                Text("No selected image")
            }

            TextField("Enter image URL", text: $imageURLString)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Scan image via URL...") {
                loadImageFromURL()
            }
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(20)
            Image(uiImage: selectedImage ?? UIImage()) //UIImage() is empty image, just in case selectedImage is nil
                .resizable()    // it makes image adjustable for all dimensions of screens
                .aspectRatio(contentMode: .fit) //ratio of width and height will change proportionally
                .frame(width: 100, height: 100)
        }
        .padding()
        .onAppear {
            loadPokemonLocally()
        }
    }

    private func loadImageFromURL() {
        guard let url = URL(string: imageURLString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in   //asynchronous HTTP request for downloading data from the given URL
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)") //checks if there was an error during the data download and print it
                return
            }

            if let data = data, let uiImage = UIImage(data: data) { //checks if the data was successfully downloaded and if it can be converted into a UIImage
                DispatchQueue.main.async {
                    selectedImage = uiImage
                    checkQRCode(from: uiImage)
                }
            }
        }.resume()
    }
    
    private func checkQRCode(from image: UIImage) { //declares a private function named checkQRCode that takes a UIImage as a parameter
        guard let ciImage = CIImage(image: image) else { //try to convert the input UIImage into a CIImage (Core Image representation)
            print("Couldn't convert UIImage to CIImage")
            return
        }

        let context = CIContext(options: nil) //this creates a CIContext, which is necessary for using Core Image features
        
        //it creates a QR code detector (CIDetector) with a specific accuracy level (CIDetectorAccuracyHigh)
        if let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) {
            let features = detector.features(in: ciImage) //It uses the detector to find QR code in the given CIImage and stores them in the features array

            for feature in features as! [CIQRCodeFeature] { //It iterates through each feature checking that the features are of type CIQRCodeFeature
                if let messageString = feature.messageString, let number = Int(messageString) { //it tyr to extract QR code content and convert it to an integer
                    if (1...1010).contains(number) {
                        if scannedNumbers.contains(number) {
                            qrCodeContent = "Pokemon already scanned."
                        } else {
                            //$0 - syntax used in Swift to refer to the current element of the array - similar to this in C\C++
                            //if a Pokemon with the matching number is found in the array pokemonIndex
                            if let pokemonIndex = viewModel.pokemoni.firstIndex(where: { $0.number == number }) {
                                //it updates properties with the Pokemon's information
                                scannedPokemonName = viewModel.pokemoni[pokemonIndex].name
                                scannedPokemonSpecies = viewModel.pokemoni[pokemonIndex].species
                                scannedPokemonWeight = viewModel.pokemoni[pokemonIndex].weight
                                scannedPokemonHeight = viewModel.pokemoni[pokemonIndex].height

                                qrCodeContent = "\(number) - \(scannedPokemonName!)"
                                scannedNumbers.append(number) //adds the number to the scanned numbers array

                                savePokemonLocally(pokemon: viewModel.pokemoni[pokemonIndex])
                            }
                        }
                    } else {
                        qrCodeContent = "Pokemon not found."
                    }
                } else {
                    qrCodeContent = nil
                }
            }
        }
    }
    // uses a JSONEncoder to convert the Pokemon object into a JSON-encoded Data which is then stored in the user defaults with the key "selectedPokemonData
    private func savePokemonLocally(pokemon: Pokemon) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(pokemon)
            UserDefaults.standard.set(data, forKey: "selectedPokemonData")
        } catch {
            print("Error encoding Pokemon: \(error.localizedDescription)")
        }
    }

    private func loadPokemonLocally() {
        if let data = UserDefaults.standard.data(forKey: "selectedPokemonData") {
            do {
                let decoder = JSONDecoder()// it uses a JSONDecoder to decode the data back into a Pokemon object
                let loadedPokemon = try decoder.decode(Pokemon.self, from: data)
                selectedPokemon = loadedPokemon //the decoded Pokemon object is then assigned to the selectedPokemon property
            } catch {
                print("Error decoding Pokemon: \(error.localizedDescription)")
            }
        }
    }
}
