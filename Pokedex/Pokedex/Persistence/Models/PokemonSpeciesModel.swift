//
//  PokemonSpeciesModel.swift
//  Pokedex
//
//  Created by Drew Brunning on 9/1/23.
//

import CoreData
import Foundation

struct PokemonSpeciesModel {
    let id: Int
    let name: String
    let displayNames: [String:String]?
    let imageURL: URL?
    let weight: Int
    let height: Int
    let pokedexEntryText: String?
    let types: [PokemonType]?
    let isLoaded: Bool
    var objectID: NSManagedObjectID?
    
    var displayName: String? {
        displayName(for: Locale.current)
    }
    
    func displayName(for locale: Locale) -> String? {
        guard let language = locale.language.languageCode?.identifier else { return nil }
        
        return displayNames?[language]
    }
}

enum PokemonType: Int {
    case normal = 1
    case fighting = 2
    case flying = 3
    case poison = 4
    case ground = 5
    case rock = 6
    case bug = 7
    case ghost = 8
    case steel = 9
    case fire = 10
    case water = 11
    case grass = 12
    case electric = 13
    case psychic = 14
    case ice = 15
    case dragon = 16
    case dark = 17
    case fairy = 18
    case unknown = 19
    case shadow = 10002
    
    init(name: String) {
        switch name {
        case "normal":
            self = .normal
        case "fighting":
            self = .fighting
        case "flying":
            self = .flying
        case "poison":
            self = .poison
        case "ground":
            self = .ground
        case "rock":
            self = .rock
        case "bug":
            self = .bug
        case "ghost":
            self = .ghost
        case "steel":
            self = .steel
        case "fire":
            self = .fire
        case "water":
            self = .water
        case "grass":
            self = .grass
        case "electric":
            self = .electric
        case "psychic":
            self = .psychic
        case "ice":
            self = .ice
        case "dragon":
            self = .dragon
        case "dark":
            self = .dark
        case "fairy":
            self = .fairy
        case "unknown":
            self = .unknown
        case "shadow":
            self = .shadow
        default:
            self = .unknown
        }
    }
    
    var displayName: String? {
        displayName(for: Locale.current)
    }
    
    func displayName(for locale: Locale) -> String? {
        return nil
    }
}

extension PokemonSpeciesModel {
    init(entity: PokemonSpeciesEntity) {
        id = Int(entity.id)
        name = entity.name
        displayNames = entity.displayNames
        imageURL = entity.imageURL
        weight = Int(entity.weight)
        height = Int(entity.height)
        pokedexEntryText = entity.pokedexEntryText
        // Types
        types = nil
        isLoaded = entity.isLoaded
        objectID = entity.objectID
    }
}

extension PokemonSpeciesEntity {
    func setProperties(from model: PokemonSpeciesModel) {
        id = Int64(model.id)
        name = model.name
        displayNames = model.displayNames
        imageURL = model.imageURL
        weight = Int64(model.weight)
        height = Int64(model.height)
        pokedexEntryText = model.pokedexEntryText
        isLoaded = model.isLoaded
        // Types
    }
}
