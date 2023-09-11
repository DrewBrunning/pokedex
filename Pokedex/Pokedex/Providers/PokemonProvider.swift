//
//  PokemonProvider.swift
//  Pokedex
//
//  Created by Drew Brunning on 9/1/23.
//

import Combine
import Foundation
import PokemonAPI

class PokemonProvider: ObservableObject {
    private var pokemonRepository: PokemonRepository
    private var pokemonService: PokemonService
    
    private var pagedObject: PKMPagedObject<PKMPokemonSpecies>?
    private var pokemonSubject = CurrentValueSubject<[PokemonSpeciesModel], Error>([])
    
    private var loadingSpecies = Set<String>()
    
    // MARK: Public
    @Published
    var isLoading = false
    
    var pokemonPublisher: AnyPublisher<[PokemonSpeciesModel], Error> {
        pokemonSubject.eraseToAnyPublisher()
    }
    
    init(pokemonRepository: PokemonRepository = PokemonRepository(), pokemonService: PokemonService = PokemonAPI().pokemonService) {
        self.pokemonRepository = pokemonRepository
        self.pokemonService = pokemonService
    }
    
    func loadMorePokemon() {
        guard !isLoading else { return }
        
        isLoading = true
        Task {
            do {
                guard let nextSpeciesPage = try await fetchNextPageOfSpeciesList() else { return }
                let speciesNames = nextSpeciesPage.compactMap { $0.name }
                
                // Check the repository cache so we don't override values we've fully loaded already
                let cached = try await pokemonRepository.getPokemon(with: speciesNames).filter { $0.isLoaded }
                let cachedNames = cached.compactMap { $0.name }
                let cacheMisses = speciesNames.filter { !cachedNames.contains($0) }
                
                var loadedSpecies = [PKMPokemonSpecies]()
                for name in cacheMisses {
                    let species = try await pokemonService.fetchPokemonSpecies(name)
                    loadedSpecies.append(species)
                }

                let models = loadedSpecies.map { species in
                    PokemonSpeciesModel(id: species.id ?? -1,
                                        name: species.name ?? "Unknown Pokemon",
                                        displayNames: species.displayNames,
                                        imageURL: nil,
                                        weight: -1,
                                        height: -1,
                                        pokedexEntryText: nil, // FIXME: Flavor Text
                                        types: nil, // FIXME: Types
                                        isLoaded: false)
                }
                
                try await pokemonRepository.addPokemon(models)
                let allPokemon = try await pokemonRepository.getPokemon()
                pokemonSubject.send(allPokemon)
                
                // Asynchronously load details
                let immutableSpecies = loadedSpecies
                Task {
                    await loadDetails(for: immutableSpecies)
                }
            } catch {
                pokemonSubject.send(completion: .failure(error))
            }
            isLoading = false
        }
    }
    
    func loadDetails(for speciesName: String) {
        guard !loadingSpecies.contains(speciesName) else { return }
        
        loadingSpecies.insert(speciesName)
        
        Task {
            do {
                // Check repository cache before trying to load
                let cached = try await pokemonRepository.getPokemon(with: speciesName)
                if cached?.isLoaded == true {
                    loadingSpecies.remove(speciesName)
                    return
                }
                
                let species = try await pokemonService.fetchPokemonSpecies(speciesName)
                if let model = try await fetchDetails(for: species) {
                    try await pokemonRepository.addPokemon(model)
                    let allPokemon = try await pokemonRepository.getPokemon()
                    pokemonSubject.send(allPokemon)
                } else {
                    print("Failed to load \(speciesName)")
                }
            } catch {
                pokemonSubject.send(completion: .failure(error))
            }
            
            loadingSpecies.remove(speciesName)
        }
    }
    
    func getDetails(for speciesName: String) async throws -> PokemonSpeciesModel {
        // Check cache
        if let cached = try await pokemonRepository.getPokemon(with: speciesName), cached.isLoaded {
            return cached
        }
        
        // If needed load from service
        let species = try await pokemonService.fetchPokemonSpecies(speciesName)
        guard let model = try await fetchDetails(for: species) else {
            throw CoreDataRepositoryError.createFailure // FIXME: Fail to fetch error
        }
        try await pokemonRepository.addPokemon(model)
        
        // Return value
        return model
    }
    
    // MARK: Private
    private func loadDetails(for speciesPage: [PKMPokemonSpecies]) async {
        do {
            var pokemon = [PokemonSpeciesModel]()
            for species in speciesPage {
                if let model = try await fetchDetails(for: species) {
                    pokemon.append(model)
                }
            }
            
            try await pokemonRepository.addPokemon(pokemon)
            
            let allPokemon = try await pokemonRepository.getPokemon()
            pokemonSubject.send(allPokemon)
        } catch {
            pokemonSubject.send(completion: .failure(error))
        }
        
        let speciesNames = speciesPage.compactMap { $0.name }
        speciesNames.forEach { loadingSpecies.remove($0) }
    }
    
    private func fetchNextPageOfSpeciesList() async throws -> [PKMNamedAPIResource<PKMPokemonSpecies>]? {
        guard pagedObject == nil || pagedObject?.hasNext == true else {
            return nil
        }
        
        let state: PaginationState<PKMPokemonSpecies>
        if let pagedObject  {
            state = .continuing(pagedObject, .next)
        } else {
            state = .initial(pageLimit: 20)
        }
        
        pagedObject = try await pokemonService.fetchPokemonSpeciesList(paginationState: state)
        return pagedObject?.results as? [PKMNamedAPIResource<PKMPokemonSpecies>]
    }
    
    private func fetchDetails(for species: PKMPokemonSpecies) async throws -> PokemonSpeciesModel? {
        var defaultPokemon: PKMPokemon?
        var pokemonList = [PKMPokemon]()
        for pokemonName in species.pokemonNames {
            let pokemon = try await pokemonService.fetchPokemon(pokemonName)
            if pokemon.isDefault ?? false {
                defaultPokemon = pokemon
            }
            pokemonList.append(pokemon)
            
            /*
            var inflatedForms = [PKMPokemonForm]()
            var defaultForm: PKMPokemonForm?
            if let forms = pokemon.forms {
                for form in forms {
                    if let name = form.name {
                        let inflatedForm = try await pokemonService.fetchPokemonForm(name)
                        inflatedForms.append(inflatedForm)
                        if inflatedForm.isDefault {
                            defaultForm = inflatedForm
                        }
                    }
                }
            }
             */
        }
        
        guard let pokemon = defaultPokemon ?? pokemonList.first else {
            return nil
        }
        
        return PokemonSpeciesModel(id: species.id ?? -1,
                                   name: species.name ?? "Unknown Pokémon",
                                   displayNames: species.displayNames ?? [String: String](),
                                   imageURL: URL(string: pokemon.sprites?.frontDefault ?? ""),
                                   weight: pokemon.weight ?? -1,
                                   height: pokemon.height ?? -1,
                                   pokedexEntryText: species.flavorTextEntries?.first(where: { $0.language?.name == Locale.current.language.languageCode?.identifier })?.flavorText, // FIXME: Pokedex entry text
                                   types: nil, // FIXME: Types
                                   isLoaded: true)
    }
}

// MARK: - Extensions
extension PKMPokemonSpecies {
    var pokemonNames: [String] {
        varieties?.compactMap({ $0.pokemon?.name }) ?? []
    }
    
    var displayNames: [String: String]? {
        names?.reduce(into: [String: String](), { partial, structure in
            if let name = structure.language?.name {
                partial[name] = structure.name
            }
        })
    }
}

// MARK: - Mock for previews and tests
class MockPokemonProvider: PokemonProvider {
    
    override var pokemonPublisher: AnyPublisher<[PokemonSpeciesModel], Error> {
        return listSubject.eraseToAnyPublisher()
    }
    
    private var listSubject = CurrentValueSubject<[PokemonSpeciesModel], Error>([])
    
    private var bulbasaurList: [PokemonSpeciesModel] = [
        PokemonSpeciesModel(id: 1,
                            name: "bulbasaur",
                            displayNames: ["en": "Bulbasaur"],
                            imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png"),
                            weight: 69,
                            height: 7,
                            pokedexEntryText: "A strange seed was planted on its back at birth. The plant sprouts and grows with this POKéMON.",
                            types: nil,
                            isLoaded: true),
        PokemonSpeciesModel(id: 2,
                            name: "ivysaur",
                            displayNames: ["en": "Ivysaur"],
                            imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/2.png"),
                            weight: 130,
                            height: 10,
                            pokedexEntryText: "When the bulb on its back grows large, it appears to lose the ability to stand on its hind legs.",
                            types: nil,
                            isLoaded: true),
        PokemonSpeciesModel(id: 3,
                            name: "venusaur",
                            displayNames: ["en": "Venusaur"],
                            imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/3.png"),
                            weight: 1000,
                            height: 20,
                            pokedexEntryText: "The plant blooms when it is absorbing solar energy. It stays on the move to seek sunlight.",
                            types: nil,
                            isLoaded: true)
    ]
    
    override func loadMorePokemon() {
        listSubject.send(bulbasaurList)
    }
    
    override func loadDetails(for speciesName: String) {
        // Empty
    }
    
    override func getDetails(for speciesName: String) async throws -> PokemonSpeciesModel {
        guard let pokemon = bulbasaurList.first(where: { $0.name == speciesName }) else {
            return PokemonSpeciesModel(id: -1,
                                       name: speciesName,
                                       displayNames: ["en" : speciesName],
                                       imageURL: nil,
                                       weight: -1,
                                       height: -1,
                                       pokedexEntryText: "This is a mocked Pokemon",
                                       types: nil,
                                       isLoaded: true)
        }
        
        return pokemon
    }
}
