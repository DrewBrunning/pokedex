//
//  PokemonView.swift
//  Pokedex
//
//  Created by Drew Brunning on 8/31/23.
//

import SwiftUI

struct PokemonDetailView: View {
    @ObservedObject var pokemon: PokemonSpeciesDetails
    
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                Spacer()
                AsyncImage(url: pokemon.imageURL)
                
                VStack {
                    Text(pokemon.displayName)
                        .font(.title)
                        .padding([.top, .horizontal], 16)
                    
                    Text(pokemon.pokedexEntryText)
                        .font(.caption)
                        .padding(.all, 16)
                    
                    Grid(horizontalSpacing: 32, verticalSpacing: 32) {
                        GridRow {
                            VStack(alignment: .leading) {
                                Text("Height")
                                    .font(.headline)
                                Text(pokemon.height)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Weight")
                                    .font(.headline)
                                Text(pokemon.weight)
                            }
                        }
                    }
                    .padding([.horizontal, .bottom], 32)
                }
                .background(Color(uiColor: UIColor.systemBackground))
                .cornerRadius(16)
                
                Spacer()
            }
            Spacer()
        }
        .background(Color(uiColor: UIColor.systemGroupedBackground))
    }
}

struct PokemonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonDetailView(pokemon: PokemonSpeciesDetails(name: "bulbasaur", pokemonProvider: MockPokemonProvider()))
    }
}
