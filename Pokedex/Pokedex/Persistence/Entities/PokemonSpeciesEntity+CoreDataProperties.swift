//
//  PokemonSpeciesEntity+CoreDataProperties.swift
//  Pokedex
//
//  Created by Drew Brunning on 9/1/23.
//
//

import Foundation
import CoreData


extension PokemonSpeciesEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PokemonSpeciesEntity> {
        return NSFetchRequest<PokemonSpeciesEntity>(entityName: "PokemonSpeciesEntity")
    }

    @NSManaged public var displayNames: [String: String]?
    @NSManaged public var height: Int64
    @NSManaged public var id: Int64
    @NSManaged public var imageURL: URL?
    @NSManaged public var name: String
    @NSManaged public var pokedexEntryText: String?
    @NSManaged public var weight: Int64
    @NSManaged public var types: NSOrderedSet?
    @NSManaged public var isLoaded: Bool

}

// MARK: Generated accessors for types
extension PokemonSpeciesEntity {

    @objc(insertObject:inTypesAtIndex:)
    @NSManaged public func insertIntoTypes(_ value: PokemonTypeEntity, at idx: Int)

    @objc(removeObjectFromTypesAtIndex:)
    @NSManaged public func removeFromTypes(at idx: Int)

    @objc(insertTypes:atIndexes:)
    @NSManaged public func insertIntoTypes(_ values: [PokemonTypeEntity], at indexes: NSIndexSet)

    @objc(removeTypesAtIndexes:)
    @NSManaged public func removeFromTypes(at indexes: NSIndexSet)

    @objc(replaceObjectInTypesAtIndex:withObject:)
    @NSManaged public func replaceTypes(at idx: Int, with value: PokemonTypeEntity)

    @objc(replaceTypesAtIndexes:withTypes:)
    @NSManaged public func replaceTypes(at indexes: NSIndexSet, with values: [PokemonTypeEntity])

    @objc(addTypesObject:)
    @NSManaged public func addToTypes(_ value: PokemonTypeEntity)

    @objc(removeTypesObject:)
    @NSManaged public func removeFromTypes(_ value: PokemonTypeEntity)

    @objc(addTypes:)
    @NSManaged public func addToTypes(_ values: NSOrderedSet)

    @objc(removeTypes:)
    @NSManaged public func removeFromTypes(_ values: NSOrderedSet)

}

extension PokemonSpeciesEntity : Identifiable {

}
