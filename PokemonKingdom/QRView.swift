//
//  QRView.swift
//  PokemonKingdom
//
//  Created by Stjepan Stojčević on 02.11.2023..
//

import SwiftUI
import Foundation

struct QRView: View {
    @State private var selectedImage: UIImage? = nil
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
            Text("Pokemons: \(scannedNumbers.map(String.init).joined(separator: ", "))")

            if selectedImage != nil {
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
                                Text("Pokemon not found.")
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            )
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }

                if let qrCodeContent = qrCodeContent {
                    Text(qrCodeContent)
                        .padding()


                    if let scannedPokemonSpecies = scannedPokemonSpecies {
                        Text("Species: \(scannedPokemonSpecies)")
                            .padding()
                    }
                    if let scannedPokemonHeight = scannedPokemonHeight{
                        Text("Height: \(scannedPokemonHeight)")
                            .padding()
                    }
                    if let scannedPokemonWeight = scannedPokemonWeight{
                        Text("Weight: \(scannedPokemonWeight)")
                            .padding()
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
            .background(Color.gray) // Dodano postavljanje boje pozadine
            .foregroundColor(.white) // Dodano postavljanje boje teksta
            .cornerRadius(20)

        }
        .padding()
    }

    private func loadImageFromURL() {
        guard let url = URL(string: imageURLString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                return
            }

            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    selectedImage = uiImage
                    checkQRCode(from: uiImage)
                }
            }
        }.resume()
    }

    private func checkQRCode(from image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            print("Couldn't convert UIImage to CIImage")
            return
        }

        let context = CIContext(options: nil)

        if let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) {
            let features = detector.features(in: ciImage)

            for feature in features as! [CIQRCodeFeature] {
                if let messageString = feature.messageString, let number = Int(messageString) {
                    if (1...1010).contains(number) {
                        if scannedNumbers.contains(number) {
                            qrCodeContent = "Pokemon already scanned."
                        } else {
                            if let pokemonIndex = viewModel.pokemoni.firstIndex(where: { $0.number == number }) {
                                scannedPokemonName = viewModel.pokemoni[pokemonIndex].name
                                scannedPokemonSpecies = viewModel.pokemoni[pokemonIndex].species
                                scannedPokemonWeight = viewModel.pokemoni[pokemonIndex].weight
                                scannedPokemonHeight = viewModel.pokemoni[pokemonIndex].height

                                qrCodeContent = "\(number) - \(scannedPokemonName!)"
                                scannedNumbers.append(number)
                            }
                        }
                    } else {
                        qrCodeContent = "Number not in the interval."
                    }
                } else {
                    qrCodeContent = nil
                }
            }
        }
    }
}
