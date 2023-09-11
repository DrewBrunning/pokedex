//
//  PokemonSpeciesDetailsTests.swift
//  PokedexTests
//
//  Created by Drew Brunning on 9/11/23.
//

@testable import Pokedex
import Combine
import XCTest

final class PokemonSpeciesDetailsTests: XCTestCase {
    
    var cancellables = [AnyCancellable]()
    
    @MainActor
    func testMockedProperties() async throws {
        let pokemonDetails = PokemonSpeciesDetails(name: "defaultValues", pokemonProvider: MockPokemonProvider())
        XCTAssertEqual(pokemonDetails.number, "000")
        XCTAssertEqual(pokemonDetails.displayName, "Unknown Pokemon")
        XCTAssertEqual(pokemonDetails.weight, "???")
        XCTAssertEqual(pokemonDetails.height, "???")
        XCTAssertEqual(pokemonDetails.pokedexEntryText, "")
        XCTAssertNil(pokemonDetails.imageURL)
        XCTAssertNil(pokemonDetails.error)
    }
    
    @MainActor
    func testBulbasaurProperties() async throws {
        let pokemonDetails = PokemonSpeciesDetails(name: "bulbasaur", pokemonProvider: MockPokemonProvider())
        
        // Initial is mocked
        XCTAssertEqual(pokemonDetails.number, "000")
        XCTAssertEqual(pokemonDetails.displayName, "Unknown Pokemon")
        XCTAssertEqual(pokemonDetails.weight, "???")
        XCTAssertEqual(pokemonDetails.height, "???")
        XCTAssertEqual(pokemonDetails.pokedexEntryText, "")
        XCTAssertNil(pokemonDetails.imageURL)
        XCTAssertNil(pokemonDetails.error)
        
        let expectation = XCTestExpectation(description: "Bulbasaur loaded")
        
        pokemonDetails.$number.sink { _ in
            expectation.fulfill()
        }.store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 1)
        
        XCTAssertEqual(pokemonDetails.number, "001")
        XCTAssertEqual(pokemonDetails.displayName, "Bulbasaur")
        XCTAssertEqual(pokemonDetails.weight, "15.212 lb")
        XCTAssertEqual(pokemonDetails.height, "27.559 in")
        XCTAssertEqual(pokemonDetails.pokedexEntryText, "A strange seed was planted on its back at birth. The plant sprouts and grows with this POKéMON.")
        XCTAssertNotNil(pokemonDetails.imageURL)
        XCTAssertNil(pokemonDetails.error)
    }
}
