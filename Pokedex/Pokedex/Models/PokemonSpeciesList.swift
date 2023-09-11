//
//  PokemonListCache.swift
//  Pokedex
//
//  Created by Drew Brunning on 8/31/23.
//

import Combine
import Foundation

@MainActor
class PokemonSpeciesList: ObservableObject {
    @Published var list = [PokemonListItem]()
    @Published var error: Error?
    @Published var isLoading = false
    
    let pokemonProvider: PokemonProvider
    
    private var cancellable: AnyCancellable?
    private var loadingCancellable: AnyCancellable?
    
    init(pokemonProvider: PokemonProvider = PokemonProvider()) {
        self.pokemonProvider = pokemonProvider
        cancellable = pokemonProvider.pokemonPublisher.sinkToResult { result in
            switch result {
            case .success(let models):
                let list = models.map {
                    PokemonListItem(id: $0.id,
                                    name: $0.name,
                                    displayName: $0.displayName,
                                    imageURL: $0.imageURL,
                                    isLoaded: $0.isLoaded)
                }
                DispatchQueue.main.async {
                    self.list = list
                    self.objectWillChange.send()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.error = error
                }
            }
        }
        loadingCancellable = pokemonProvider.$isLoading.sink { isLoading in
            DispatchQueue.main.async {
                self.isLoading = isLoading
            }
        }
    }
    
    func loadMore() {
        pokemonProvider.loadMorePokemon()
    }
    
    func loadDetails(for name: String) {
        pokemonProvider.loadDetails(for: name)
    }
}

struct PokemonListItem: Hashable {
    let id: Int
    let name: String
    let displayName: String
    let imageURL: URL?
    let isLoaded: Bool
    
    init(id: Int, name: String, displayName: String? = nil, imageURL: URL?, isLoaded: Bool) {
        self.id = id
        self.name = name
        self.displayName = displayName ?? name
        self.imageURL = imageURL
        self.isLoaded = isLoaded
    }
}
