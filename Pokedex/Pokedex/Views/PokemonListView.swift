//
//  PokemonListView.swift
//  Pokedex
//
//  Created by Drew Brunning on 8/31/23.
//

import PokemonAPI
import SwiftUI

struct PokemonListView: View {
    @StateObject var pokemonList: PokemonSpeciesList
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .center) {
                    ForEach(Array(pokemonList.list.enumerated()), id: \.element) { index, pokemon in
                        NavigationLink(destination: PokemonDetailView(pokemon: PokemonSpeciesDetails(name: pokemon.name, pokemonProvider: pokemonList.pokemonProvider))) {
                            VStack {
                                Spacer()
                                PokemonListItemView(pokemon: pokemon)
                                    .background(Color(uiColor: UIColor.systemBackground))
                                    .cornerRadius(16)
                                    .onAppear {
                                        // Load details if needed
                                        if !pokemon.isLoaded {
                                            pokemonList.loadDetails(for: pokemon.name)
                                        }
                                        
                                        // Lazily load the next page as we scroll
                                        if index >= pokemonList.list.count - 10 && !pokemonList.isLoading {
                                            pokemonList.loadMore()
                                        }
                                    }
                                Spacer()
                            }
                        }
                    }
                }
            }
            .background(Color(uiColor: UIColor.systemGroupedBackground))
        }
        .onAppear {
            if pokemonList.list.isEmpty {
                pokemonList.loadMore()
            }
        }
        
        if pokemonList.isLoading {
            ProgressView()
        }
    }
}

struct PokemonListItemView: View {
    @State var pokemon: PokemonListItem
    
    var body: some View {
        HStack {
            Spacer()
            DynamicStack {
                Spacer()
                AsyncImage(url: pokemon.imageURL)
                Text(pokemon.displayName)
                Spacer()
            }
            Spacer()
        }
    }
}

// MARK: - Preview
struct PokemonListView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonListView(pokemonList: PokemonSpeciesList(pokemonProvider: MockPokemonProvider()))
            .previewInterfaceOrientation(.portrait)
            .previewDisplayName("Pokemon List Portrait")
        
        PokemonListView(pokemonList: PokemonSpeciesList(pokemonProvider: MockPokemonProvider()))
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDisplayName("Pokemon List Landscape")
    }
}
