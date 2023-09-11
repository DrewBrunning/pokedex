//
//  PokedexApp.swift
//  Pokedex
//
//  Created by Drew Brunning on 8/31/23.
//

import SwiftUI

@main
struct PokedexApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            PokemonListView(pokemonList: PokemonSpeciesList())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
