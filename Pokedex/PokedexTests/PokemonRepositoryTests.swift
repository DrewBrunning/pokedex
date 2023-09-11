//
//  PokemonRepositoryTests.swift
//  PokedexTests
//
//  Created by Drew Brunning on 9/3/23.
//

@testable import Pokedex
import CoreData
import XCTest

final class PokemonRepositoryTests: XCTestCase {
    private var pokemonRepository: PokemonRepository!
    private var container: NSPersistentContainer!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let persistence = PersistenceController(inMemory: true)
        container = persistence.container
        pokemonRepository = PokemonRepository(container: container)
    }
    
    func testGetEmptyPokemon() async throws {
        // Nothing in, nothing out
        let result = try await pokemonRepository.getPokemon()
        XCTAssertEqual(result.count, 0)
    }
    
    func testGetPokemon() async throws {
        // Write to CoreData directly
        let newObject = NSEntityDescription.insertNewObject(forEntityName: PokemonSpeciesEntity.description(), into: container.viewContext) as! PokemonSpeciesEntity
        newObject.name = "bulbasaur"
        newObject.id = 1
        newObject.displayNames = ["en": "Bulbasaur"]
        newObject.height = 7
        newObject.weight = 69
        newObject.types = nil // FIXME: Types
        
        try container.viewContext.save()
        
        // Get result from repository
        let result = try await pokemonRepository.getPokemon()
        
        XCTAssertEqual(result.count, 1)
        
        let pokemon = result.first
        XCTAssertNotNil(pokemon)
        XCTAssertEqual(pokemon?.name, newObject.name)
        XCTAssertEqual(pokemon?.id, Int(newObject.id))
        XCTAssertEqual(pokemon?.displayNames, newObject.displayNames)
        XCTAssertEqual(pokemon?.height, Int(newObject.height))
        XCTAssertEqual(pokemon?.weight, Int(newObject.weight))
    }
    
    func testAddPokemon() async throws {
        // Write with repository
        let bulbasaur = PokemonSpeciesModel(id: 1,
                                            name: "bulbabaur",
                                            displayNames: ["en": "Bulbasaur"],
                                            imageURL: nil,
                                            weight: 69,
                                            height: 7,
                                            pokedexEntryText: nil,
                                            types: nil,
                                            isLoaded: true)
        try await pokemonRepository.addPokemon(bulbasaur)
        
        // Check from the CoreData directly
        let fetchRequest = PokemonSpeciesEntity.fetchRequest()
        let result = try container.viewContext.fetch(fetchRequest)
        
        XCTAssertEqual(result.count, 1)
        
        let pokemon = result.first
        XCTAssertNotNil(pokemon)
        XCTAssertEqual(pokemon?.name, bulbasaur.name)
        XCTAssertEqual(pokemon?.id, Int64(bulbasaur.id))
        XCTAssertEqual(pokemon?.displayNames, bulbasaur.displayNames)
        XCTAssertEqual(pokemon?.height, Int64(bulbasaur.height))
        XCTAssertEqual(pokemon?.weight, Int64(bulbasaur.weight))
        XCTAssert(pokemon?.isLoaded == true)
    }
    
    func testUpdatePokemon() async throws {
        // Write with repository
        let bulbasaur1 = PokemonSpeciesModel(id: 1,
                                             name: "bulbabaur",
                                             displayNames: ["en": "Bulbasaur"],
                                             imageURL: nil,
                                             weight: 69,
                                             height: 7,
                                             pokedexEntryText: nil,
                                             types: nil,
                                             isLoaded: false)
        try await pokemonRepository.addPokemon(bulbasaur1)
        
        let bulbasaur2 = PokemonSpeciesModel(id: 1,
                                             name: "bulbabaur",
                                             displayNames: ["en": "Bulbasaur"],
                                             imageURL: nil,
                                             weight: 71,
                                             height: 7,
                                             pokedexEntryText: nil,
                                             types: nil,
                                             isLoaded: true)
        try await pokemonRepository.addPokemon(bulbasaur2)
        
        // Check from the CoreData directly
        let fetchRequest = PokemonSpeciesEntity.fetchRequest()
        let result = try container.viewContext.fetch(fetchRequest)
        
        XCTAssertEqual(result.count, 1)
        
        let pokemon = result.first
        XCTAssertNotNil(pokemon)
        XCTAssertEqual(pokemon?.name, bulbasaur2.name)
        XCTAssertEqual(pokemon?.id, Int64(bulbasaur2.id))
        XCTAssertEqual(pokemon?.displayNames, bulbasaur2.displayNames)
        XCTAssertEqual(pokemon?.height, Int64(bulbasaur2.height))
        XCTAssertEqual(pokemon?.weight, Int64(bulbasaur2.weight))
        XCTAssert(pokemon?.isLoaded == true)
    }
}
