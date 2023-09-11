//
//  PokemonSpeciesDetails.swift
//  Pokedex
//
//  Created by Drew Brunning on 9/6/23.
//

import Combine
import Foundation

@MainActor
class PokemonSpeciesDetails: ObservableObject {
    private var name: String
    
    let pokemonProvider: PokemonProvider
    
    @Published var number: String = "000"
    @Published var displayName: String = "Unknown Pokemon"
    @Published var imageURL: URL?
    @Published var weight: String = "???"
    @Published var height: String = "???"
    @Published var pokedexEntryText: String = ""
    @Published var error: Error?
    
    init(name: String, pokemonProvider: PokemonProvider) {
        self.name = name
        self.pokemonProvider = pokemonProvider
        
        Task {
            do {
                let model = try await pokemonProvider.getDetails(for: name)
                updateValues(from: model)
            } catch {
                self.error = error
            }
        }
    }
    
    private func updateValues(from model: PokemonSpeciesModel) {
        number = "\(model.id)"
        displayName = model.displayName ?? displayName
        imageURL = model.imageURL
        weight = formatWeight(model.weight)
        height = formatHeight(model.height)
        pokedexEntryText = model.pokedexEntryText ?? ""
    }
    
    private func formatWeight(_ weight: Int) -> String {
        let measurement = Measurement(value: Double(weight) / 10.0, unit: UnitMass.kilograms)
        let converted = measurement.converted(to: UnitMass(forLocale: Locale.current))
        let weightFormatter = MeasurementFormatter()
        weightFormatter.unitOptions = .naturalScale
        return weightFormatter.string(from: converted)
    }
    
    private func formatHeight(_ height: Int) -> String {
        let measurement = Measurement(value: Double(height) / 10.0, unit: UnitLength.meters)
        let converted = measurement.converted(to: UnitLength(forLocale: Locale.current))
        let heightFormatter = MeasurementFormatter()
        heightFormatter.unitOptions = .naturalScale
        return heightFormatter.string(from: converted)
    }
}
