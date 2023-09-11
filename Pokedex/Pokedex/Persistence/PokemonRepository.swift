//
//  PokemonRepository.swift
//  Pokedex
//
//  Created by Drew Brunning on 9/1/23.
//

import Combine
import CoreData
import Foundation

public enum CoreDataRepositoryError: Error {
    case createFailure
    case objectNotFound
    case objectIDNotFound
    case incorrectThread
}

actor PokemonRepository {
    private let container: NSPersistentContainer
    
    private var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    private var backgroundContext: NSManagedObjectContext {
        container.newBackgroundContext()
    }
    
    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
    }
    
    /// Get list of Pokemon
    func getPokemon(with names: [String]? = nil) async throws -> [PokemonSpeciesModel] {
        let fetchRequest = PokemonSpeciesEntity.fetchRequest()
        if let names, !names.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "name IN %@", names)
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let backgroundContext = backgroundContext
        let models = try await backgroundContext.perform {
            let entities = try backgroundContext.fetch(fetchRequest)
            return entities.compactMap { PokemonSpeciesModel(entity: $0) }
        }
        
        return models
    }
    
    /// Get single Pokemon
    func getPokemon(with name: String) async throws -> PokemonSpeciesModel? {
        try await getPokemon(with: [name]).first
    }
    
    /// Add/update list of Pokemon
    func addPokemon(_ pokemon: [PokemonSpeciesModel]) async throws {
        let fetchRequest = PokemonSpeciesEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name IN %@", pokemon.map { $0.name })
        
        let backgroundContext = backgroundContext
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        try await backgroundContext.perform {
            // Get existing entities and put them into a dictionary for quick lookup as we loop through Pokemon being added
            let existingEntities = try backgroundContext.fetch(fetchRequest)
            let existingMap = existingEntities.reduce(into: [String: PokemonSpeciesEntity]()) { partialResult, entity in
                partialResult[entity.name] = entity
            }
            
            // For each Pokemon, see if it's existing or new, and find or create the object to update
            try pokemon.forEach { objectModel in
                let object: PokemonSpeciesEntity
                if let existingObject = existingMap[objectModel.name] {
                    object = existingObject
                } else if let newObject = NSEntityDescription.insertNewObject(forEntityName: PokemonSpeciesEntity.description(), into: backgroundContext) as? PokemonSpeciesEntity {
                    object = newObject
                } else {
                    throw CoreDataRepositoryError.createFailure
                }
                
                // Update properties
                object.setProperties(from: objectModel)
            }
            
            try self.save(backgroundContext)
        }
    }
    
    /// Add/update single Pokemon
    func addPokemon(_ pokemon: PokemonSpeciesModel) async throws {
        try await addPokemon([pokemon])
    }
    
    /// Get info for list of types
    func getTypeInfo(for names: [String]) async throws -> [AnyObject] {
        // TODO: Types
        return []
    }
    
    /// Add/update type info
    func addTypeInfo() async throws {
        // TODO: Types
    }
    
    private func save(_ context: NSManagedObjectContext) throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                throw error
            }
        }
    }
}
