//
//  PokemonSpeciesListTests.swift
//  PokedexTests
//
//  Created by Drew Brunning on 9/11/23.
//

@testable import Pokedex
import XCTest

final class PokemonSpeciesListTests: XCTestCase {
    private var pokemonList: PokemonSpeciesList!

    @MainActor
    override func setUpWithError() throws {
        pokemonList = PokemonSpeciesList(pokemonProvider: MockPokemonProvider())
    }

    func testLoadMore() async {
        let initialList = await pokemonList.list
        XCTAssertEqual(initialList.count, 0)
        
        await pokemonList.loadMore()
        let finalList = await pokemonList.list
        XCTAssertEqual(finalList.count, 3)
    }

    func testLoadDetails() async throws {
        let pokemon = try await pokemonList.pokemonProvider.getDetails(for: "bulbasaur")
        XCTAssertEqual(pokemon.name, "bulbasaur")
        XCTAssertEqual(pokemon.weight, 69)
        XCTAssertEqual(pokemon.height, 7)
        XCTAssertEqual(pokemon.displayName, "Bulbasaur")
        XCTAssertNotNil(pokemon.imageURL)
    }
}
